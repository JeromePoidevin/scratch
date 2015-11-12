from Tkinter import *

class Cell :

    def __init__ (self,x,y) :
        self.x = x
        self.y = y

    def draw (self) :
        global w
        w.create_oval(self.x,self.y,50,50,fill="red")

class MacroCell :

    def __init__ (self,x,y,sizex,sizey) :
        self.y = y
        self.sizey = sizey
        self.x = x
        self.sizex = sizex
        self.centrex = x+0.5*sizex
        self.centrey = y+0.5*sizey

    def draw (self) :
        global w
        global fpsize
        w.create_rectangle(self.x,self.y,(self.sizex/fpsize),(self.sizey/fpsize))


master = Tk()

w = Canvas(master, width=500, height=500)
w.pack()

fpx = float(1200)
fpy = float(900)
fpsize = max(fpx,fpy)
w.create_rectangle(0,0,(fpx/fpsize),(fpy/fpsize))

c1 = Cell(100,100)
c2 = Cell(300,300)
c1.draw()
c2.draw()
m1 = MacroCell(100,100,200,200)
m2 = MacroCell(300,300,50,100)
m1.draw()
m2.draw()

mainloop()

#w.create_line(0, 0, 200, 100)
#w.create_line(0, 100, 200, 0, fill="red", dash=(4, 4))


