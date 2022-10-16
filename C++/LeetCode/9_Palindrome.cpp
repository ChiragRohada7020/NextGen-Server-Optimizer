


class Solution {
public:
    bool isPalindrome(int x) {
        bool ans;

    string y=to_string(x);
    int length=y.length();

    for (int i = 0; i < length/2; i++)
    {
        if(y[i]==y[length-(i+1)])
        {
            ans=true;
        }
        else
        {
              ans=false;
              break;
        }
    }
    return ans;
    }
};
