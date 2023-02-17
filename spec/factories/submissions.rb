# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :submission do
    source { "sauce" }
    language { LanguageGroup.find_by_identifier("c++").current_language }
    score { nil }
    judge_log { nil }
    user_id { 0 }
    problem_id { 0 }
    created_at { Time.now }
    updated_at { created_at }
    factory :adding_submission do
      language { LanguageGroup.find_by_identifier("c++").current_language }
      source { <<sourcecode }
        #include <cstdio>
        using namespace std;
        int main() {
          FILE* in = fopen("add.in", "r");
          FILE* out = fopen("add.out", "w");
          int a,b;
          if (!fscanf(in, "%d %d", &a, &b)) return 1;
          int c = a+b;
          fprintf(out, "%d\\n",c);
          return 0;
        }
sourcecode
    end
    factory :adding_submission_stdio do
      language { LanguageGroup.find_by_identifier("c++").current_language }
      source { <<sourcecode }
        #include <cstdio>
        using namespace std;
        int main() {
          int a,b;
          if (!scanf("%d %d", &a, &b)) return 1;
          int c = a+b;
          printf("%d\\n",c);
          return 0;
        }
sourcecode
    end
    factory :adding_char_submission do
      language { LanguageGroup.find_by_identifier("c++").current_language }
      source { <<sourcecode }
        #include <cstdio>
        using namespace std;
        int main() {
          FILE* in = fopen("add.in", "r");
          FILE* out = fopen("add.out", "w");
          int a,b;
          if (!fscanf(in, "%d %d", &a, &b)) return 1;
          signed char c = a+b;
          fprintf(out, "%d\\n",(int)c);
          return 0;
        }
sourcecode
    end
    factory :adding_unsigned_submission do
      language { LanguageGroup.find_by_identifier("c++").current_language }
      source { <<sourcecode }
        #include <cstdio>
        using namespace std;
        int main() {
          FILE* in = fopen("add.in", "r");
          FILE* out = fopen("add.out", "w");
          int a,b;
          if (!fscanf(in, "%d %d", &a, &b)) return 1;
          unsigned int c = a+b;
          fprintf(out, "%u\\n",(int)c);
          return 0;
        }
sourcecode
    end
  end
end
