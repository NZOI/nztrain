# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :submission do
    source "sauce"
    language "C++"
    score nil
    user_id 0
    problem_id 0
    created_at { Time.now }
    updated_at { created_at }
    judge_output "Judge"
    debug_output "Debug"
    factory :adding_submission do
      language "C++"
      source <<sourcecode
        #include <cstdio>
        using namespace std;
        int main() {
          FILE* in = fopen("add.in", "r");
          FILE* out = fopen("add.out", "w");
          int a,b;
          fscanf(in, "%d %d", &a, &b);
          int c = a+b;
          fprintf(out, "%d\n",c);
          return 0;
        }
sourcecode
    end
    factory :adding_char_submission do
      language "C++"
      source <<sourcecode
        #include <cstdio>
        using namespace std;
        int main() {
          FILE* in = fopen("add.in", "r");
          FILE* out = fopen("add.out", "w");
          int a,b;
          fscanf(in, "%d %d", &a, &b);
          signed char c = a+b;
          fprintf(out, "%d\n",(int)c);
          return 0;
        }
sourcecode
    end
    factory :adding_unsigned_submission do
      language "C++"
      source <<sourcecode
        #include <cstdio>
        using namespace std;
        int main() {
          FILE* in = fopen("add.in", "r");
          FILE* out = fopen("add.out", "w");
          int a,b;
          fscanf(in, "%d %d", &a, &b);
          unsigned int c = a+b;
          fprintf(out, "%d\n",(int)c);
          return 0;
        }
sourcecode
    end
  end
end
