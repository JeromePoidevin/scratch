
########################################
## import

import sys, re

## import Tk ...

if ( sys.version_info < (2,7) ) :
    print( 'Error : requires python 2.7+ or 3.1+' )

elif ( sys.version_info < (3,0) ) :
    import Tkinter as tk
    import ttk as ttk

else :
    import tkinter as tk
    import tkinter.ttk as ttk

## failed to change fonts ...
#ttk.Style().configure('TButton', font='Luxi Sans 8')
#ttk.Style().configure('Treeview', font='Luxi Sans 8')
#ttk.Style().lookup('TButton','font')
#ttk.Style().lookup('Treeview','font')



########################################
## some global declarations

debug = False

tree_rows = [ None ]  # item 0 is void because CTSNode starts at 1

TOP = None


########################################
## Buttons

def setup_buttons() :
    global root
    global find_level
    global find_min
    global find_max
    global find_skew
    global find_name

    ## left buttons

    left = tk.Frame(root)
    left.grid(column=0,row=0)

    collapse_all_button = tk.Button(left,width=1,text='- -')  # Collapse All
    collapse_all_button.grid(column=0,row=1)
    collapse_all_button.configure(command=lambda : expand_collapse_all(False) )

    collapse_button = tk.Button(left,width=1,text='-')  # Collapse
    collapse_button.grid(column=0,row=2)
    collapse_button.configure(command=lambda : expand_collapse(False) )

    expand_button = tk.Button(left,width=1,text='+')  # Expand
    expand_button.grid(column=0,row=3)
    expand_button.configure(command=lambda : expand_collapse(True) )

    expand_all_button = tk.Button(left,width=1,text='+ +')  # Expand All
    expand_all_button.grid(row=4)
    expand_all_button.configure(command=lambda : expand_collapse_all(True) )

    ## bottom entries (row 200)

    find_level= tk.StringVar()
    tk.Label(root,text="level ==",width=8).grid(row=200,column=1)
    find_level_box=tk.Entry(root,textvariable=find_level,background='white',width=8)
    find_level_box.grid(row=200,column=2,sticky='w')
   #find_level_box.bind('<Return>',find_change);

    find_min= tk.StringVar()
    tk.Label(root,text="min <=",width=8).grid(row=200,column=3)
    find_min_box=tk.Entry(root,textvariable=find_min,background='white',width=8)
    find_min_box.grid(row=200,column=4,sticky='w')
   #find_min_box.bind('<Return>',find_change);

    find_max= tk.StringVar()
    tk.Label(root,text="max >=",width=8).grid(row=200,column=5)
    find_max_box=tk.Entry(root,textvariable=find_max,background='white',width=8)
    find_max_box.grid(row=200,column=6,sticky='w')
   #find_max_box.bind('<Return>',find_change);

    find_skew= tk.StringVar()
    tk.Label(root,text="skew >=",width=8).grid(row=200,column=7)
    find_skew_box=tk.Entry(root,textvariable=find_skew,background='white',width=8)
    find_skew_box.grid(row=200,column=8,sticky='w')
   #find_skew_box.bind('<Return>',find_change);

    ## bottom entries (row 201)

    find_name= tk.StringVar()
    tk.Label(root,text="<regexp>",width=8).grid(row=201,column=1)
    find_name_box=tk.Entry(root,textvariable=find_name,background='white',width=100)
    find_name_box.grid(row=201,column=2,columnspan=100,sticky='we')
   #find_name_box.bind('<Return>',find_change);

    ## bottom buttons (row 300)

    bottom = tk.Frame(root)
    bottom.grid(column=2,columnspan=100,row=300,sticky='w')

    find_all_button = tk.Button(bottom,width=10,text='Find (All)')
    find_all_button.grid(column=1,row=0)
    find_all_button.configure(command=lambda : find_filter(hideall=False,rows='1') )  # 1 is TOP

    find_button = tk.Button(bottom,width=10,text='Find')
    find_button.grid(column=2,row=0)
    find_button.configure(command=lambda : find_filter(hideall=False,rows=tree.selection()) )

    filter_all_button = tk.Button(bottom,width=10,text='Filter (All)')
    filter_all_button.grid(column=3,row=0)
    filter_all_button.configure(command=lambda : find_filter(hideall=True,rows='1') )  # 1 is TOP

    filter_button = tk.Button(bottom,width=10,text='Filter')
    filter_button.grid(column=4,row=0)
    filter_button.configure(command=lambda : find_filter(hideall=True,rows=tree.selection()) )

    clear_button = tk.Button(bottom,width=10,text='Clear')
    clear_button.grid(column=5,row=0)
    clear_button.configure(command=find_clear)

    print_button = tk.Button(bottom,width=10,text='Print')
    print_button.grid(column=6,row=0,sticky='e')
    print_button.configure(command=print_tree )



########################################
## Tree : create & define appearance

def setup_tree() :
    global root
    global tree,tree_columns

    tree_columns = ('level','inst/pin','fanout','cone','ff','min','max')

    tree = ttk.Treeview(root,columns=tree_columns,show="headings")
    tree.grid(row=0,column=1,columnspan=100,rowspan=100,sticky='nwes')

    scroll = tk.Scrollbar(root, orient=tk.VERTICAL, command=tree.yview)
    scroll.grid(row=0,column=100,rowspan=100,sticky='ns')
    tree.configure( yscrollcommand=scroll.set )

    root.rowconfigure(0,weight=1)
    root.columnconfigure(2,weight=1)

    ## tree columns
    
   #tree.heading('#0',text='tree')
   #tree.column('#0',width=1,anchor='w')

    for col in tree_columns :
        tree.heading(col,text=col)
       #tree.heading(col, command=lambda c=col: sort_by_column(c, 0) )
        tree.column(col,width=60,anchor='center',stretch=False)

    tree.column('inst/pin',width=800,anchor='w',stretch=True)

    ## tags & bind

    tree.tag_configure('bg_grey',background='lightgrey')
    tree.tag_configure('fg_blue',foreground='blue')
    tree.tag_configure('fg_green',foreground='dark green')

   #tree.bind('<<TreeviewSelect>>',row_select)


########################################

def expand_collapse(show) :
    global tree
    global tree_rows
    for row in tree.selection() :
        ctsnode = tree_rows[int(row)]
        ctsnode.show_hide_below(show)
        if not show : ctsnode.show = True
    display_tree(TOP)

def expand_collapse_all(show) :
    global TOP
    TOP.show_hide_below(show)
    if not show : TOP.show = True
    display_tree(TOP)

def find_filter(hideall,rows) :
    global tree
    global tree_rows
    global find_level
    global find_min
    global find_max
    global find_skew
    global find_name
    global debug

    fname  = find_name.get()
    flevel = find_level.get()
    fmin   = find_min.get()
    fmax   = find_max.get()
    fskew  = find_skew.get()
    if fname=='' : fname = None
    if flevel=='' : flevel = None
    else          : flevel = int(flevel)
    if fmin==''   : fmin = None
    else          : fmin = int(fmin)
    if fmax==''   : fmax = None
    else          : fmax = int(fmax)
    if fskew==''  : fskew = None
    else          : fskew = int(fskew)

    if debug :
        print "find_filter : hideall=%s : rows=%s : level=%s : min=%s max=%s skew=%s : name=%s" % (hideall,str(rows),flevel,fmin,fmax,fskew,fname)

    for row in rows :
        ctsnode = tree_rows[int(row)]
        ctsnode.find_tree( hideall=hideall , name=fname , level=flevel , min=fmin , max=fmax , skew=fskew )
    display_tree(TOP)

def find_clear() :
    global find_level
    global find_name
    find_level.set('')
    find_min.set('')
    find_max.set('')
    find_skew.set('')
    find_name.set('')
    # clear highlights
    find_filter(hideall=False,rows='1')  # 1 is TOP
    display_tree(TOP)

def print_tree() :
    global TOP
    with open("clock_tree_browser.txt",'w') as f :
        f.write( "num # level # inst/pin : show : down : fanout cone ff min max" )
        TOP.print_tree(f)
       #f.close()   # automatically with 'with'


########################################
## Tree : display / refresh

def color_row(ctsnode) :
    if   ( ctsnode.level < 0 ) : return 'fg_blue'
    elif ( ctsnode.highlight ) : return 'fg_green'
    else : return ''


def create_tree(ctsnode) :
    global tree

    if ctsnode.up==None : up = ''
    else : up = ctsnode.up.n
    n = ctsnode.n
    values = list()
    values.append( ctsnode.level )
    values.append( ctsnode.name )
    values.append( ctsnode.fanout )
    values.append( ctsnode.cone )
    values.append( ctsnode.ff )
    values.append( ctsnode.min )
    values.append( ctsnode.max )

    ## row does not exist in GUI : create
    tree.insert(up,'end',n,text='', values=values ) # match tree_columns
    ## pointer to the original ctsnode
    tree_rows.append( ctsnode )

    for d in ctsnode.down :
        create_tree(d)


def display_tree(ctsnode) :
    global tree

    if ctsnode.up==None : up = ''
    else : up = ctsnode.up.n
    n = ctsnode.n
    show = ctsnode.show

    if show :
        tree.move(n,up,'end')
        tree.item(n,tag=color_row(ctsnode),open=True)
        for d in ctsnode.down :
            display_tree(d)

    else :
        tree.detach(n)



########################################
## Tree : click on widget

def tcl2py(tcl_row):
    # row appears to be a tcl list (with white_space and curly_braces)
    # - split on white_spaces , which is ok if module has no white_space
    # - remove curly_braces
    py_row = [ col.strip('{}') for col in tcl_row.split(' ',1) ]
    return py_row


########################################
## Root <F9> : print_all

def print_all(event):
    global tree
    print("====")
    for row,attr in tree.items() :
        print( '%s : %s' % (row,attr) )

########################################
## window manager

def ctgui() :

    global root
    global TOP

    root = tk.Tk()

    setup_buttons()
    setup_tree()
    create_tree(TOP)
    display_tree(TOP)

    root.bind_all('<F9>',print_all)

    ###############

    root.mainloop()


########################################
## standalone __main__

if ( __name__ == "__main__" ) :

    from clock_tree_CTSNode import CTSNode

    debug = True

    TOP = CTSNode('TOP',None,level=-2)
    clk = CTSNode('clk',TOP)
    for i in "abcdefghijklmnopqrstuvwxyz" :
        l = CTSNode(i,clk)
        for j in "123" :
            CTSNode(i+j,l)

    ctgui()

