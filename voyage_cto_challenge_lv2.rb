# by bussealle
# ruby version 2.3.1

require 'json'

class Engineer
  attr_reader :id, :team
  def initialize(engineer,log)
    @id = engineer["id"]
    @team = engineer["team"]
    @dekiru = engineer["chottodekiru"]
    @recent_review = log.select {|s| s["reviewee"] == @id}.slice(0..2) #直近3つのlog
  end
  public
  def dekiru?(lang)
    @dekiru.include?(lang)
  end
  def recent?(engineer)
    @recent_review.any?{|e| e["reviewer"] == engineer.id}
  end
end

class Codereview
  @@Reviewer_NUM = 3
  def initialize(reviewee_id:, review_lang:, json_path:)
    json_hash = Hash.new
    File.open(json_path) {|file| json_hash = JSON.load(file)}
    initial_error_check(json_hash, reviewee_id)
    @engineers = json_hash["engineers"].map {|m| Engineer.new(m, json_hash["recent_review_log"])}
    @reviewee = @engineers.find {|e| e.id == reviewee_id}
    @review_lang = review_lang
  end

  public
  def random_select_reviewers
    engineers = @engineers
    reviewee = @reviewee
    review_lang = @review_lang
    reviewers = Array.new
    [*0...engineers.length].shuffle.each do |i|
      next if skip_reviewer?(engineers[i])

      if reviewers.length < @@Reviewer_NUM
        reviewers << engineers[i]
        if reviewers.length == @@Reviewer_NUM
          if (1...@@Reviewer_NUM).include?(reviewers.select{|s| s.team == reviewee.team}.length)
            break
          else
            reviewers.pop
          end
        end
      end
    end
    extract_ids(reviewers)
  end

  private
  def skip_reviewer?(engineer)
    reviewee = @reviewee
    review_lang = @review_lang
    return true if engineer == reviewee
    return true if reviewee.recent?(engineer)
    if reviewee.dekiru?(review_lang)
      return true if engineer.team != reviewee.team && !engineer.dekiru?(review_lang)
    else
      return true unless engineer.dekiru?(review_lang)
    end
    return false
  end
  def extract_ids(reviewers)
    reviewer_ids = reviewers.map{|m| m.id}
    until reviewer_ids.length == @@Reviewer_NUM
      reviewer_ids << "N/A"
    end
    reviewer_ids
  end
  def initial_error_check(json_hash, reviewee_id)
    raise "ERROR: There are no key \'engineers\' in JSON" unless json_hash.include?("engineers")
    raise "ERROR: There are no key \'recent_review_log\' in JSON" unless json_hash.include?("recent_review_log")
    raise "ERROR: Cannot find given revewee #{reviewee_id} in \'engineers\'" unless json_hash["engineers"].any? { |e| e["id"] == reviewee_id }
  end
end

raise "\nHOW TO USE\nexecute: arg1:<id>, arg2:<language>, arg3:<path to JSON>\ntest: arg1:<testfile>, arg2:<path to JSON>" unless ARGV.length == 3 || ARGV.length == 2
if ARGV.length == 2
  autoload(:Codereview_test, "./"+ARGV[0])
  Codereview_test
else
  output = Codereview.new(reviewee_id: ARGV[0], review_lang: ARGV[1], json_path: ARGV[2]).random_select_reviewers
  puts output.join(",")
end
