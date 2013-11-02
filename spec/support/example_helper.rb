module ExampleHelper
  def array_to_result(a)
    a.each.with_object(Queue.new) {|token, q|
      q.push token
    }
  end

  def result_to_array(q)
    result_array = []
    result_array << q.shift until q.empty?

    result_array
  end
end
