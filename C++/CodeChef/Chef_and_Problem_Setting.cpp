#include <iostream>
#include <bits/stdc++.h>

using namespace std;

int main()
{
    // your code goes here
    int t;
    cin >> t;
    while (t--)
    {
        int n, m;
        cin >> n >> m;
        string str1;
        string str;

        string answer;

        for (int i = 0; i < n; i++)
        {
            cin >> str1;
            cin >> str;
            int k = 0;
            for (int j = 0; j < m; j++)
            {
                if (str[j] == '1')
                    k++;
            }
            if (str1 == "correct" && k == m || str1 == "wrong" && k < m)
            {
                if (answer == "INVALID" || answer == "WEAK")
                {
                }
                else
                {
                    answer = "FINE";
                }
            }

            else if (str1 == "correct" && k < m)
            {
                answer = "INVALID";
            }
            else if (str1 == "wrong" && k == m)
            {
                if (answer == "INVALID")
                {
                }
                else
                {
                    answer = "WEAK";
                }
            }
            else
            {
            }
        }
        cout << answer << endl;
    }
    return 0;
}
