import sys
from tkinter import *
import guimaker

menuBar = [('File', 0,
                    [('Open', 0, lambda:0),
                     ('Quit', 0, sys.exit)]),
                ('Edit', 0, 
                    [('Cut',   0, lambda:0),
                     ('Paste', 0, lambda:0)]),
                ('Top', 0, 
                    [('Top1',   0, [
                        ('Top11', 0, lambda:0),
                        ('Top12', 0, lambda:0)
                    ]),
                     ('Top2', 0, lambda:0)])]
class Gui(guimaker.GuiMakerWindowMenu):
        def __init__(self, parent, guiNum=123):
            guimaker.GuiMakerWindowMenu.__init__(self, parent)
            self.parent=parent
            self.parent.title(str(guiNum)+" SF/ETX-1P Boot Downloads")

        def start(self):
            self.menuBar = menuBar
        def makeWidgets(self):
            frm = Frame(self, relief=GROOVE, bd=2)
            frm.pack(side=LEFT, fill=Y)
            self.lblSW = Label(frm, text="SW Ver: ", width=33).pack(anchor=W)
            self.lblFlashImg = Label(frm, text="Flash Image: ", width=33).pack(anchor=W)

       # print('Gui', guiNum)
    



if __name__ == '__main__':
    if len(sys.argv)>1:
        guiNum = sys.argv[1]
    else:
        guiNum = 199
    print(guiNum)

    root = Tk()
    #win = Toplevel(root)

            
    Gui(root, guiNum)
    root.mainloop()