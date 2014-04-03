

class ReposeAnalyzer < Scout::Plugin
  def build_report
    search_time = `date "+%d-%m-%Y-%R" -d "1 min ago"`.chomp

    matched_lines = `grep '#{search_time}' /var/log/repose/http_repose.log | grep -v powerapi | grep -v ^$ | awk '{print $2,$34}'`.split(/\n/)
    response_times = matched_lines.map {|x| c = x.split(" "); {:time => c[0].split("=").last.to_f, :http_status => c[1].split("=").last}}

    responses = response_times.count

    if responses > 0
      average_response_times = (response_times.inject(0) {|sum, x| sum + x[:time]} / responses).round(2)
      remember(:previous_response_average => average_response_times)

      report(:requests => responses)
      report(:overall_average_response_times => average_response_times)
    else
      remember(:previous_response_average, memory(:previous_response_average))

      report(:requests => 0)
      report(:overall_average_response_times => memory(:previous_response_average))
    end

    repose_2xx_responses = response_times.select {|x| x[:http_status].match(/^2/)}.count
    repose_3xx_responses = response_times.select {|x| x[:http_status].match(/^3/)}.count
    repose_4xx_responses = response_times.select {|x| x[:http_status].match(/^4/)}.count
    repose_5xx_responses = response_times.select {|x| x[:http_status].match(/^5/)}.count

    report(:repose_2xx_responses => repose_2xx_responses)
    report(:repose_3xx_responses => repose_3xx_responses)
    report(:repose_4xx_responses => repose_4xx_responses)
    report(:repose_5xx_responses => repose_5xx_responses)
  end

end
