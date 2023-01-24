require 'csv'

module Contests
  class ContestExporter < BaseExporter

    def to_csv(contest, include_unranked_contestants)
      problems = contest.problem_set.problems

      scoreboard = CSV.generate do |csv|
        csv << ["Rank", "User ID", "Real Name", "Username", "School", "Year"] + problems.map{ |p| p.name } + ["Total Score", "Time"]

        num_ranked = 0
        rank = nil
        previous_record = nil

        contest.scoreboard.each do |record|
          is_ranked = !contest.only_rank_official_contestants || (record.school && record.school_year)
          next unless is_ranked || include_unranked_contestants

          if is_ranked
            num_ranked += 1
            rank = num_ranked unless previous_record && previous_record.score == record.score && previous_record.time_taken == record.time_taken
            previous_record = record
          end

          display_rank = is_ranked ? rank : nil

          row = [display_rank, record.user&.id, record.user&.name, record.user&.username, is_ranked ? record.school&.name : nil, is_ranked ? record.school_year : nil]
          problems.each do |prob|
            row << record["score_#{prob.id}"]
          end
          row += [record.score, format("%d:%02d:%02d",record.time_taken.to_i/3600,record.time_taken.to_i/60%60,record.time_taken.to_i%60)]
          csv << row
        end
      end
    end

    def export(path, options = {})
      contest = subject
      subpath = File.expand_path('submissions', path)
      dir.mkdir(subpath)
      submissions = []


      file.open(File.expand_path('scoreboard.csv', path), 'wb') do |f|
        f.write to_csv(contest, false)
        tempfiles << f
      end

      if contest.only_rank_official_contestants
        file.open(File.expand_path('unofficial_scoreboard.csv', path), 'wb') do |f|
          f.write to_csv(contest, true)
          tempfiles << f
        end
      end

      contest.scoreboard.each do |record|
        next if record.user.nil?
        contest.problem_set.problems.each do |prob|
          submissions += contest.get_submissions(record.user.id, prob.id)
        end
      end

      submissions.each do |sub|
        file.open(File.expand_path("#{sub.id}#{sub.language.extension}", subpath), 'w') do |f|
          f.write sub.source
          tempfiles << f
        end
      end

      file.open(File.expand_path('contest.json', path), 'w') do |f|
        f.write contest.to_json(include: {
          problem_set: {include: :problems},
          contestants: {include: :school},
          contest_relations: {},
          scoreboard: {},
        })
        tempfiles << f
      end

      file.open(File.expand_path('submissions.json', path), 'w') do |f|
        f.write submissions.to_json(
          include: {language: {only: :name}},
          except: [:judge_log, :source],
        )
        tempfiles << f
      end

      path
    end

    def around_export(path, options)
      super
    end

  end
end

