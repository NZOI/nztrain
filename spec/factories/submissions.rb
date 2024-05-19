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
    factory :binary_search_submission do
      language { LanguageGroup.find_by_identifier("c++").current_language }
      source { <<sourcecode }
        #include <iostream>
        using namespace std;
        int main() {
          int lo=0, hi, attempts, result;
          cin >> hi >> attempts;
          while (hi - lo > 1) {
            int mid = (lo + hi) / 2;
            cout << mid << endl;
            cin >> result;
            if ( result == 0 )
              return 0;
            else if ( result < 0 )
              hi = mid;
            else
              lo = mid + 1;
          }
          cout << lo << endl;
        }
sourcecode
    end
    factory :binary_search_submission_incorrect do
      language { LanguageGroup.find_by_identifier("c++").current_language }
      source { <<sourcecode }
        #include <iostream>
        using namespace std;
        int main() {
          int hi, attempts, result;
          cin >> hi >> attempts;
          for (int i = 0; i < hi; i++) {
            cout << i << endl;
            cin >> result;
            if (result == 0)
              break;
          }
        }
sourcecode
    end
    factory :binary_search_submission_wall_tle do
      language { LanguageGroup.find_by_identifier("c++").current_language }
      source { <<sourcecode }
        #include <iostream>
        using namespace std;
        int main() {
          int hi, attempts, result;
          cin >> hi >> attempts;
          for (int i = 0; i < hi; i++) {
            //cout << i << endl;
            cin >> result;
          }
        }
sourcecode
    end
    factory :integer_encoding_submission do
      language { LanguageGroup.find_by_identifier("c++").current_language }
      source { <<sourcecode }
        #include <iostream>
        #include <string>
        #include <algorithm>
        using namespace std;
        int main() {
          int mode, N = 0;
          std::string encoded_string;
          cin >> mode;
          if (mode == 1) {
            cin >> N;
            while (N) {
              encoded_string += 'a' + (N & 1);
              N >>= 1;
            }
            encoded_string += 'a';
            reverse(encoded_string.begin(), encoded_string.end());
            cout << encoded_string << endl;
          }
          if (mode == 2) {
            cin >> encoded_string;
            for (char c : encoded_string) {
              N <<= 1;
              N += c > 'a';
            }
            cout << N << endl;
          }
        }
sourcecode
    end
    factory :integer_encoding_submission_mle do
      language { LanguageGroup.find_by_identifier("c++").current_language }
      source { <<sourcecode }
        #include <iostream>
        #include <string>
        #include <algorithm>
        using namespace std;
        int main() {
          std::array<char, 1024*1024*10> arr;  // x2 = 20 MiB; should MLE
          arr.fill(-1);

          int mode, N = 0;
          std::string encoded_string;
          cin >> mode;
          if (mode == 1) {
            cin >> N;
            while (N) {
              encoded_string += 'a' + (N & 1);
              N >>= 1;
            }
            encoded_string += 'a';
            reverse(encoded_string.begin(), encoded_string.end());
            cout << encoded_string << endl;
          }
          if (mode == 2) {
            cin >> encoded_string;
            for (char c : encoded_string) {
              N <<= 1;
              N += c > 'a';
            }
            cout << N << endl;
          }
        }
sourcecode
    end
  end
end
