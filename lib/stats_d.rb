class StatsD
  SMOOTHING_FACTOR = 0.25

  def self.url
    ENV['STATSD_URL']
  end

  def self.user
    ENV['STATSD_USER']
  end

  def self.password
    ENV['STATSD_PASS']
  end

  def self.rpm_namespace
    ENV['STATSD_RPM_NAMESPACE']
  end

  def self.get_rpm_average(start, finish)
    period = "from=#{start.to_i}&until=#{finish.to_i}"
    points = self.history(self.rpm_namespace, period)
    average = (points.sum{ |p| p[:y] } / points.count) * 1000
  end

  def self.api_call(url)
    conn = Faraday.new(self.url, :ssl => {:verify => false})
    conn.basic_auth(self.user, self.password)
    JSON.parse(conn.get(url).body)[0]
  end

  def self.history(metric, period)
    json = api_call("/render/?#{period}&target=#{metric}&format=json")
    set = json['datapoints'].collect do |point|
      next if point[0].nil?
      {x: point[1], y: point[0]}
    end
    set.compact
  end

  def self.exponential_moving_average(history)    
    set = history.collect { |hash| hash[:y] }
    set.last * SMOOTHING_FACTOR + ((1 - SMOOTHING_FACTOR) * set.sum / set.length)
  end

  def self.moving_average(history, count)   
    recent = []

    history.collect do |hash|
      recent.push hash[:y]
      hash[:y] = recent.sum / recent.length
      recent.shift if recent.length >= count
      hash
    end 
  end

  def self.standard_dev_of_the_interval(standard_deviations, means, path_fragment, window)
    counts_per_time_slice = history(path_fragment + '.count', window).map{|sampled_count| { :x => sampled_count[:x],  :y => sampled_count[:y] * 10.0 } }
    sums = history(path_fragment + '.sum', window)
    timestamps = standard_deviations.map{ |value| value[:x] }

    normalized_sums = remove_missing_values_from_history(sums, timestamps)
    normalized_counts_per_time_slice = remove_missing_values_from_history(counts_per_time_slice, timestamps)
    normalized_standard_deviations = remove_missing_values_from_history(standard_deviations, timestamps)
    normalized_means = remove_missing_values_from_history(means, timestamps)

    calculate_standard_dev_of_the_interval(normalized_sums, normalized_counts_per_time_slice, normalized_standard_deviations, normalized_means)
  end

  def self.calculate_standard_dev_of_the_interval(sums, counts_per_time_slice, standard_deviations, means)
    sum_square = lambda{ |x,y| x**2 + y**2  }

    summation = sums.reduce(&:+)
    counts_summation = counts_per_time_slice.reduce(&:+)
    counts_summation_times_sum_square = counts_per_time_slice.each_with_index.map do |count, i|
      if standard_deviations[i] && means[i]
        count * sum_square.call(standard_deviations[i], means[i])
      else
        nil
      end
    end.compact.reduce(&:+)

    e_i = summation.to_f / counts_summation.to_f
    e_i_square = counts_summation_times_sum_square.to_f / counts_summation.to_f
    Math.sqrt(e_i_square - (e_i ** 2))
  end

  private_class_method :calculate_standard_dev_of_the_interval

  def self.remove_missing_values_from_history(data, timestamps)
    data.select{ |point| timestamps.include?(point[:x]) }.map{ |point| point[:y] }
  end
end
