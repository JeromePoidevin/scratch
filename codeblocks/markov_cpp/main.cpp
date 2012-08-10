#include <iostream>
#include <fstream>
#include <vector>
#include <map>
#include <deque>
#include <string>
#include <cstdlib> // rand()

using namespace std;

enum { DEBUG=2 } ;
enum { NPREFIX=2 , MAXGEN=100 } ; // markov
const char * NONWORD = "\t";

typedef deque<string> Prefix;
map<Prefix, vector<string> > statetab;

// add : add a word to list-of-suffixes, update prefix
void add(Prefix & prefix, const string & s)
{
    if (prefix.size()==NPREFIX)
    {
        statetab[prefix].push_back(s);
        // statetab[prefix] created if not pre-exists
        prefix.pop_front();
    }
    prefix.push_back(s);
}

// build : read from file, create hashtable with prefix_suffix
void build( ifstream & rfile )
{
    if (DEBUG) cout << "debug : BUILD\n";

    Prefix prefix;
    for (int i=0;i<NPREFIX;i++) add(prefix,NONWORD) ;

    string word;
    while (rfile >> word)
    {
        if (DEBUG>1) cout << "debug : build : " << word << "\n" ;
        add(prefix,word);
    }
}

void print_statetab()
{
}

void generate(int nwords)
{
    Prefix prefix;
    int i;
    int rnd;

    if (DEBUG) cout << "debug : GENERATE\n";

    for (i=0;i<NPREFIX;i++) add(prefix,NONWORD) ;

    for (i=0;i<nwords;i++)
    {
        vector<string> & suffix = statetab[prefix];
        rnd = rand() % suffix.size() ;
        string & w = suffix[ rnd ];

        if (DEBUG>1) cout << "debug : generate : rnd = " << rnd << " ," ;
        if (w==NONWORD) break;
        cout << " " << w ;
        if (DEBUG>1) cout << "\n" ;
        prefix.pop_front();
        prefix.push_back(w);
    }

}

int main()
{
    ifstream rfile;
    rfile.open( "../../man_gcc" , ios::in );

    build(rfile);
    rfile.close();
    print_statetab();
    generate(MAXGEN);
    return 0;
}
