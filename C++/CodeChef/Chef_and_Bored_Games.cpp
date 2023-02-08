#include <bits/stdc++.h>
using namespace std;

int OddSquares(int N, int n)
{
    return ((N - n + 1) * (N - n + 1));
}

int main()
{

    int N, n, sum = 0, t;

    cin >> t;

    while (t--)
    {
        cin >> N;
        n = 1;
        sum = 0;

        while (n <= N)
        {
            sum = sum + OddSquares(N, n);
            n += 2;
        }

        cout << sum;
        cout << endl;
    }
}