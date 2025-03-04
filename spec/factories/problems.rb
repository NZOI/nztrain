# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :problem do
    sequence(:name) {|n| "Problem #{n}" }
    statement { "Do nothing" }
    input { nil }
    output { nil }
    memory_limit { 1 }
    time_limit { 1 }
    owner_id { 0 }

    test_sets { test_cases.map{FactoryBot.create(:test_set)} }

    after(:create) do |problem|
      problem.test_cases.zip(problem.test_sets).each do |test_case, test_set|
        FactoryBot.create(:test_case_relation, :test_case => test_case, :test_set => test_set)
      end
    end

    factory :adding_problem_stdio do
      sequence(:name) {|n| "Adding problem #{n}" }
      statement { "Read two integers from input and output the sum." }
      memory_limit { 30 }
      time_limit { 1 }
      test_cases { [FactoryBot.create(:test_case, :input => "5 9", :output => "14"),
                    FactoryBot.create(:test_case, :input => "100 -50", :output => "50"),
                    FactoryBot.create(:test_case, :input => "1235 942", :output => "2177"),
                    FactoryBot.create(:test_case, :input => "-4000 123", :output => "-3877")] }

      factory :adding_problem do
        input { "add.in" }
        output { "add.out" }
      end
    end

    factory :binary_search_problem do
      name { "Binary search problem" }
      statement { "Find the target number within Q guesses. After each guess you are told whether the target is lower, higher, or correct." }
      memory_limit { 16 }
      time_limit { 0.1 }
      test_cases { [FactoryBot.create(:test_case, :input => "100 100 98"),
                    FactoryBot.create(:test_case, :input => "100000 17 37")] }

      evaluator { FactoryBot.create(:evaluator, :language => LanguageGroup.find_by_identifier("c++").current_language,
                                    :interactive_processes => 1, :source => <<~'sourcecode' ) }
        #include <csignal>
        #include <cstdlib>
        #include <cstdio>

        void grade(int score, const char* message = NULL) {
          fprintf(stdout, "%d\n", score);
          if (message)
            fprintf(stderr, "%s\n", message);
          exit(0);
        }

        int main() {
          {
            // Keep alive on broken pipes
            struct sigaction sa;
            sa.sa_handler = SIG_IGN;
            sigaction(SIGPIPE, &sa, NULL);
          }

          FILE* user_in = fdopen(5, "r");
          FILE* user_out = fdopen(6, "w");

          int N, Q, K;
          scanf("%d %d %d", &N, &Q, &K);
          fclose(stdin);
          fprintf(user_out, "%d %d\n", N, Q);
          fflush(user_out);

          int guess;
          for (int i = 0; i < Q; ++i) {
            if (fscanf(user_in, "%d", &guess) != 1) {
              grade(0, "Could not read guess");
            }
            if (guess == K) {
              fprintf(user_out, "0\n");
              fflush(user_out);
              break;
            } else if (guess < K) {
              fprintf(user_out, "1\n");
              fflush(user_out);
            } else {
              fprintf(user_out, "-1\n");
              fflush(user_out);
            }
            if (i == Q - 1) {
              grade(0, "Too many guesses");
            }
          }

          if (fscanf(user_in, "%d", &guess) != EOF)
            grade(0, "Wrong output format, trailing garbage");

          grade(1);
        }
      sourcecode
    end

    factory :integer_encoding_problem do
      name { "Integer encoding problem" }
      statement { "Send the input number between two processes using only alphabetic characters." }
      memory_limit { 16 }
      time_limit { 0.5 }
      test_cases { [FactoryBot.create(:test_case, :input => "0"),
                    FactoryBot.create(:test_case, :input => "42"),
                    FactoryBot.create(:test_case, :input => "9999")] }

      evaluator { FactoryBot.create(:evaluator, :interactive_processes => 2, :source => <<~'sourcecode' ) }
        #!/usr/bin/env python3
        import os
        import sys
        import functools
        import traceback
        import time

        print = functools.partial(print, flush=True)  # Always flush

        user1_in = os.fdopen(5, 'r')
        user1_out = os.fdopen(6, 'w')
        user2_in = os.fdopen(7, 'r')
        user2_out = os.fdopen(8, 'w')

        def grade(score, admin_message=None, user_message=None):
          if not user2_out.closed:
            try:
              print(-1, file=user2_out)
            except:
              pass
          print(score)
          if user_message is not None:
            print(user_message)
          if admin_message is not None:
            print(admin_message, file=sys.stderr)
          sys.exit(0)

        N = int(input())

        try:
          print(1, file=user1_out)
          print(N, file=user1_out)
          user1_out.close()
          encoded_string = user1_in.read(100000).strip()
        except (BrokenPipeError, ValueError):
          grade(0, traceback.format_exc())

        if user1_in.read(100000).strip():
          grade(0, "Wrong output format, trailing garbage")
        user1_in.close()

        if not encoded_string.isalpha():
          grade(0, "Invalid encoded string: " + encoded_string)

        try:
          print(2, file=user2_out)
          print(encoded_string, file=user2_out)
          user2_out.close()
          decoded_integer = int(user2_in.readline(100000))
        except (BrokenPipeError, ValueError):
          grade(0, traceback.format_exc())

        if user2_in.read(100000).strip():
          grade(0, "Wrong output format, trailing garbage")
        user2_in.close()

        if decoded_integer != N:
          grade(0, "Wrong answer")
        grade(1)
      sourcecode
    end
  end
end
