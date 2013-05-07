
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

tree_columns = ('level','inst','fanout','cone','ff')

data_tree = None


########################################
## Filter Buttons

def setup_filter() :
    global expand_collapse
    global expand_string
    global filter_string
    global filter_box

    expand_collapse = True
    filter_string = {}
    filter_box = {}

    ## create widgets : filter & tree & scroll

    expand_string = tk.StringVar()
    expand_string.set( 'Expand' )
    expand_button = tk.Button(root,width=10,textvariable=expand_string)
    expand_button.grid(row=0,column=0)
    expand_button.configure(command=expand_tree)

    filter_button = tk.Button(root,width=10,text='Filter')
    filter_button.grid(row=0,column=1)
    filter_button.configure(command=display_tree)

    clear_button = tk.Button(root,width=10,text='Clear')
    clear_button.grid(row=0,column=2)
    clear_button.configure(command=filter_clear)

    for (i,col) in enumerate( tree_columns , 1 ) :
        filter_string[col]= tk.StringVar()
        tk.Label(root,text=col).grid(row=i,column=0)
        filter_box[col]=tk.Entry(root,textvariable=filter_string[col],background='white',width=30)
        filter_box[col].grid(row=i,column=1,sticky='n')
        filter_box[col].bind('<Return>',filter_change);

    root.columnconfigure(0,weight=1)


########################################
## Tree : create & define appearance

def setup_tree() :
    global root
    global tree,tree_columns

    tree = ttk.Treeview(root,columns=tree_columns,show="headings")
    tree.grid(row=100,column=0,columnspan=3,sticky='nwes')

    scroll = tk.Scrollbar(root, orient=tk.VERTICAL, command=tree.yview)
    scroll.grid(row=100,column=3,sticky='ns')
    tree.configure( yscrollcommand=scroll.set )

    root.rowconfigure(100,weight=1)
    root.columnconfigure(1,weight=1)

    ## tree columns
    
   #tree.heading('#0',text='tree')
   #tree.column('#0',width=1,anchor='w')

    for col in tree_columns :
        tree.heading(col,text=col)
       #tree.heading(col, command=lambda c=col: sort_by_column(c, 0) )
        tree.column(col,width=10,anchor='center')

    tree.column('inst',width=100,anchor='w')

    ## tags & bind

    tree.tag_configure('bg_green',background='green' )
    tree.tag_configure('bg_orange',background='orange' )
    tree.tag_configure('bg_red',background='red' )
    tree.tag_configure('bg_grey',background='lightgrey')
    tree.tag_configure('bg_yellow',background='yellow')
    tree.tag_configure('fg_blue',foreground='blue')
    tree.tag_configure('fg_red',foreground='red')
    tree.tag_configure('red_grey',foreground='red',background='lightgrey')

   #tree.bind('<<TreeviewSelect>>',row_select)


########################################
## filter_box[col].bind('<Return>',filter_change);
## clear_button.configure(command=filter_clear)

def expand_tree() : # TODO
    global expand_collapse
    global expand_string
    global data_tree

    for (row,data) in enumerate(data_tree) :
        tree.item(row,open=expand_collapse )

    display_tree(data_tree)

    expand_collapse = not expand_collapse
    if expand_collapse : expand_string.set( 'Expand' )
    else               : expand_string.set( 'Collapse' )


def filter_change(event) : # TODO
    global data_tree
    display_tree(data_tree)


def filter_clear() : # TODO
    global filter_string
    global data_tree
    for col in filter_string :
        filter_string[col].set( '' )
    display_tree(data_tree)
    

########################################
## Tree : display / refresh

def color_row(ctsnode) :
    if   ( ctsnode.level < 0 ) : return 'fg_blue'
    else : return ''


def create_tree(ctsnode) :
    global tree

    if ctsnode.up==None : up = ''
    else : up = ctsnode.up.name
    name = ctsnode.name
    level = ctsnode.level
    fanout = ctsnode.fanout
    cone = ctsnode.cone
    ff = ctsnode.ff

    ## row does not exist : create
    tree.insert(up,'end',name,text='', values=(level,name,fanout,cone,ff) ) # match tree_columns

    for d in ctsnode.down :
        create_tree(d)


def display_tree(ctsnode) :
    global tree

    if ctsnode.up==None : up = ''
    else : up = ctsnode.up.name
    name = ctsnode.name
    show = ctsnode.show

    if show :
        tree.move(name,up,'end')
        tree.item(name,tag=color_row(ctsnode))
        for d in ctsnode.down :
            display_tree(d)

    else :
        tree.detach(name)



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
    global data_tree

    root = tk.Tk()

    setup_filter()
    setup_tree()
    create_tree(data_tree)
    display_tree(data_tree)

    root.bind_all('<F9>',print_all)

    ###############

    root.mainloop()


########################################
## standalone __main__

if ( __name__ == "__main__" ) :
    
    debug = True

    i = 0
    parent = ''
    for ip in ( 'ADC','CATB','SMAP' ) :
        for u in range(0,12) :

            ## one top-level item every 10
            level = i % 10
            if level == 0 : parent = ''
            else          : level = 1

            ## create inst
            inst = '%s/U%d' % (ip,u)

            data = { 'parent':parent , 'inst':inst , 'level':level , 'ref':'buf' , 'attr':'?' }
            data_tree.append( data )

            if debug : print( 'debug: __main__ : %s -> %s' % (inst,data) )

            ## prepare next iteration
            if level == 0 : parent = inst
            i += 1

    ctgui()



