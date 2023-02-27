#include <iostream>
using namespace std;

int main() {
	  
	  int t;
	  cin>>t;
	  while(t--)
	  {
	      int n;
	      cin>>n;
	      int arr[n];
	      int count=0;
	      int index1=-1;
	  for(int i=0;i<n;i++)
	  {
	      cin>>arr[i];
	  }
	   for(int i=0;i<n-1;i++)
	  {
	      if(arr[i]!=arr[i+1])
	      {
	          if(index1==i)
	          {
	           count++;
	           index1=i+1;
	          }
	          else
	          {
	              count=count+2;
	              index1=i+1;
	          }
	      }
	  }
	  cout<<count<<endl;
	  }
	  
	return 0;
}
