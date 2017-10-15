# by bussealle
# ruby version 2.3.1

require 'minitest/autorun'

class Codereview_test < MiniTest::Test
  @@json_path = ARGV[1]
  def test_case1
    reviewee_id = "a"
    review_lang = "ruby"
    json_path = @@json_path
    exp_outputs = [["b", "d", "e", "f", "g"],["i", "j", "q", "s"],["b", "d", "e", "f", "g", "i", "j", "q", "s"]]

    assert(arg_proccess(reviewee_id, review_lang, json_path, exp_outputs))
  end
  def test_case2
    reviewee_id = "a"
    review_lang = "javascript"
    json_path = @@json_path
    exp_outputs = [["b","d"],["i", "j", "n", "o", "p"],["b", "d", "i", "j", "n", "o", "p"]]

    assert(arg_proccess(reviewee_id, review_lang, json_path, exp_outputs))
  end
  def test_case3
    reviewee_id = "a"
    review_lang = "lisp"
    json_path = @@json_path
    exp_outputs = ["N/A","N/A","N/A"]

    assert(arg_proccess(reviewee_id, review_lang, json_path, exp_outputs))
  end
  def test_case4
    reviewee_id = "a"
    review_lang = "scala"
    json_path = @@json_path
    exp_outputs = ["s","q","N/A"]

    assert(arg_proccess(reviewee_id, review_lang, json_path, exp_outputs))
  end
  def test_case5
    reviewee_id = "a"
    review_lang = "go"
    json_path = @@json_path
    exp_outputs = [["h","i","j","k","l","m"],["h","i","j","k","l","m"],"N/A"]

    assert(arg_proccess(reviewee_id, review_lang, json_path, exp_outputs))
  end
  def test_case6
    reviewee_id = "q"
    review_lang = "php"
    json_path = @@json_path
    exp_outputs = [["e","f","g"],["n","o","p"],["n","o","p","e","f","g"]]

    assert(arg_proccess(reviewee_id, review_lang, json_path, exp_outputs))
  end

  private
  def arg_proccess(reviewee_id, review_lang, json_path, exp_outputs)
    prev_method = caller[0][/`([^']*)'/, 1]
    reviewers = Codereview.new(reviewee_id: reviewee_id, review_lang: review_lang, json_path: json_path).random_select_reviewers
    raise "exp_outputs needs #{reviewers.length} arguments" unless exp_outputs.length == reviewers.length
    test_results = Array.new
    exp_outputs.each_with_index do |exp_output,i|
      exp_output = Array.new<<exp_output unless exp_output.instance_of?(Array)
      result = exp_output.find {|a| reviewers.include?(a)}
      if result
        reviewers.each_with_index do |e,i|
          reviewers.delete_at(i) && break if result == e
        end
      else
        puts "--> error was found at argument#{i+1}: `#{exp_outputs[i]}' in `#{prev_method}'"
      end
      test_results << result
    end
    test_results.all? {|a| !a.nil?}
  end
end
