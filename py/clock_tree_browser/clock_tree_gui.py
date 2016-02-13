
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
    global find_name

    ## create buttons

    ## top

    expand_all_button = tk.Button(root,width=10,text='Expand (All)')
    expand_all_button.grid(row=0,column=0,sticky='w')
    expand_all_button.configure(command=lambda : expand_collapse_all(True) )

    expand_button = tk.Button(root,width=10,text='Expand')
    expand_button.grid(row=0,column=1,sticky='w')
    expand_button.configure(command=lambda : expand_collapse(True) )

    collapse_all_button = tk.Button(root,width=10,text='Collapse (All)')
    collapse_all_button.grid(row=0,column=2,sticky='w')
    collapse_all_button.configure(command=lambda : expand_collapse_all(False) )

    collapse_button = tk.Button(root,width=10,text='Collapse')
    collapse_button.grid(row=0,column=3,sticky='w')
    collapse_button.configure(command=lambda : expand_collapse(False) )

    print_button = tk.Button(root,width=10,text='Print')
    print_button.grid(row=0,column=99,sticky='e')
    print_button.configure(command=print_tree )

    ## bottom

    find_level= tk.StringVar()
    tk.Label(root,text="Level (int)").grid(row=200,column=0)
    find_level_box=tk.Entry(root,textvariable=find_level,background='white',width=30)
    find_level_box.grid(row=200,column=1,columnspan=100,sticky='we')
   #find_level_box.bind('<Return>',find_change);

    find_name= tk.StringVar()
    tk.Label(root,text="Name (regexp)").grid(row=201,column=0)
    find_name_box=tk.Entry(root,textvariable=find_name,background='white',width=30)
    find_name_box.grid(row=201,column=1,columnspan=100,sticky='we')
   #find_name_box.bind('<Return>',find_change);

    find_all_button = tk.Button(root,width=10,text='Find (All)')
    find_all_button.grid(row=202,column=0,sticky='w')
    find_all_button.configure(command=lambda : find_filter(hideall=False,rows='1') )  # 1 is TOP

    find_button = tk.Button(root,width=10,text='Find')
    find_button.grid(row=202,column=1,sticky='w')
    find_button.configure(command=lambda : find_filter(hideall=False,rows=tree.selection()) )

    filter_all_button = tk.Button(root,width=10,text='Filter (All)')
    filter_all_button.grid(row=202,column=2,sticky='w')
    filter_all_button.configure(command=lambda : find_filter(hideall=True,rows='1') )  # 1 is TOP

    filter_button = tk.Button(root,width=10,text='Filter')
    filter_button.grid(row=202,column=3,sticky='w')
    filter_button.configure(command=lambda : find_filter(hideall=True,rows=tree.selection()) )

    clear_button = tk.Button(root,width=10,text='Clear')
    clear_button.grid(row=202,column=99)
    clear_button.configure(command=find_clear)



########################################
## Tree : create & define appearance

def setup_tree() :
    global root
    global tree,tree_columns

    tree_columns = ('level','inst/pin','fanout','cone','ff')

    tree = ttk.Treeview(root,columns=tree_columns,show="headings")
    tree.grid(row=100,column=0,columnspan=100,sticky='nwes')

    scroll = tk.Scrollbar(root, orient=tk.VERTICAL, command=tree.yview)
    scroll.grid(row=100,column=100,sticky='ns')
    tree.configure( yscrollcommand=scroll.set )

    root.rowconfigure(100,weight=1)
    root.columnconfigure(1,weight=1)

    ## tree columns
    
   #tree.heading('#0',text='tree')
   #tree.column('#0',width=1,anchor='w')

    for col in tree_columns :
        tree.heading(col,text=col)
       #tree.heading(col, command=lambda c=col: sort_by_column(c, 0) )
        tree.column(col,width=1,anchor='center')

    tree.column('inst/pin',width=100,anchor='w')

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
    global find_name
    global debug

    fname = find_name.get()
    flevel = find_level.get()
    if debug :
        print "find_filter : hideall=%s : rows=%s : level=%s : name=%s" % (hideall,str(rows),flevel,fname)

    for row in rows :
        ctsnode = tree_rows[int(row)]
        ctsnode.find_tree( hideall=hideall , name=fname , level=flevel )
    display_tree(TOP)

def find_clear() :
    global find_level
    global find_name
    find_level.set('')
    find_name.set('')
    # clear highlights
    find_filter(hideall=False,rows='1')  # 1 is TOP
    display_tree(TOP)

def print_tree() :
    global TOP
    print "num # level # inst/pin : show : down : fanout cone ff"
    TOP.print_tree()


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
    name = ctsnode.name
    level = ctsnode.level
    fanout = ctsnode.fanout
    cone = ctsnode.cone
    ff = ctsnode.ff

    ## row does not exist in GUI : create
    tree.insert(up,'end',n,text='', values=(level,name,fanout,cone,ff) ) # match tree_columns
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

