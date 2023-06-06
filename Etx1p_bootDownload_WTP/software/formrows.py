from tkinter import *

def makeFormRow(parent, label, width=25, entWidth=25):
    var = StringVar()
    row = Frame(parent)
    lab = Label(row, text=label, relief=FLAT, width=width)
    ent = Entry(row, relief=SUNKEN, textvariable=var, width=entWidth)
    row.pack(fill=X, pady=2)
    lab.pack(side=LEFT)
    ent.pack(side=LEFT, expand=YES, fill=X)
    return ent, var

    

    