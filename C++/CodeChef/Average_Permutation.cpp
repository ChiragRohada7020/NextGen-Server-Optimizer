#include<bits/stdc++.h>
using namespace std;

int main()
{
    ios_base::sync_with_stdio(false);
    cin.tie(NULL);
    
    int t;
    cin>>t;
    while(t--)
    {
        int n;
        cin>>n;
        vector<int> vec;
        vec.push_back(n-1);
        vec.push_back(n-2);
        for(int i=1;i<n-3;i++)
        {
            vec.push_back(i);
        }
        if(n>3)
            vec.push_back(n-3);
            
        vec.push_back(n);
        for(auto &val:vec)
        {
            cout<<val<<" ";
        }
        cout<<endl;
    }
    
    return 0;
}