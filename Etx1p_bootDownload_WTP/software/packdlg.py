import re
from tkinter import *
from formrows import makeFormRow
from checkSanity import checkSanityId, lastEntrySanity, checkSanityTrace, sanity
from runZinnerApps import *


def packDialog(x, y):
    win = Toplevel()
    ## win.protocol will be defined after vars list
    #print(f'packDialog {x}, {y}')
    win.geometry("+%d+%d" %(x+20,y+20))
    win.title("Scan UUT's Barcodes")

    ents = []
    vars = []
    ent1, var1 = makeFormRow(win, label="ID Barcode")
    ents.append(ent1) ; vars.append(var1)
    ent2, var2 = makeFormRow(win, label="MainCard Traceability")
    ents.append(ent2) ; vars.append(var2)
    ent3, var3 = makeFormRow(win, label="SubCard1 Traceability")
    ents.append(ent3); vars.append(var3)

    win.protocol('WM_DELETE_WINDOW', lambda: butCancelCmd(vars, win))
    butOk = Button(win, text='OK', command=lambda: lastEntrySanity('event', ents, vars, win))
    butOk.bind('<Return>', lambda event: lastEntrySanity(event, ents, vars, win))

    butCa = Button(win, text='Cancel', command=lambda: butCancelCmd(vars, win))
    butCa.bind('<Return>', lambda event: butCancelCmd(vars, win))
    butCa.pack(side=RIGHT)
    butOk.pack(side=RIGHT)

    #entries = [ent1, ent2, ent3]
    for idx, entry in enumerate(ents):
        entry.bind('<Return>', lambda e, idx=idx: jump_cursor(e, ents, idx, vars, win))
        entry.bind('<KeyPress-Tab>', lambda e, idx=idx: jump_cursor(e, ents, idx, vars, win))
    ent3.bind('<Return>', lambda event: lastEntrySanity(event, ents, vars, win))
    ent3.bind('<Tab>', lambda event: lastEntrySanity(event, ents, vars, win))

    win.grab_set()
    ent1.focus_set()
    ent1.insert(0, "")
    win.wait_window()

    return var1.get(), var2.get(), var3.get()

def butCancelCmd(vars, win):
    vars[0].set('Cancel')
    win.destroy()
    return()


def deleteLabels():
    var1.set('')
    var2.set('')
    var3.set('')


def jump_cursor(event, ents, this_index, vars, win):
    ent = ents[this_index]
    entGet = ent.get()
    var = vars[this_index]
    var.set(entGet.strip())

    if this_index == 0:
        deleteLabels()
        if checkSanityId(ent):
            oi = getOI(entGet)
            print('jump_cursor, io: ', oi)
            if re.search('WDC/', oi) is None and re.search('12V/', oi) is None:
                ents[2].config(state=DISABLED)
                ents[1].bind('<Return>', lambda e: lastEntrySanity(event, ents, vars, win))
        else:
            return False
    elif this_index == 1:
        if not checkSanityTrace(ent):
            return False
    
    var.set(entGet.upper().strip())

    next_index = (this_index + 1) % len(ents)
    ents[next_index].focus_set()


def runPackDialog(var1, var2, var3):
    x = root.winfo_x()
    y = root.winfo_y()
    id, traceMain, traceSub1 = packDialog(x, y)

    if id == 'Cancel':
        pass
    elif id != 'Cancel':
        var1.set('')
        var2.set('')
        var3.set('')
        print(f'id:<{id}>, traceMain:<{traceMain}>, traceSub1:<{traceSub1}>')
        oi = getOI(id)
        mkt = getMkt(id)
        csl = getCsl(id)
        var1.set(f'{id}, {mkt}, {csl}')
        print('OI: ', oi, "CSL: ", csl)
        mainPcbName = getPcbName(traceMain)
        m = re.search('REV([.\d]+)I', mainPcbName)
        if m:
            mainPcbRev = m.group(1)
        else:
            mainPcbRev = ''
        print('mainPcbName: ', mainPcbName, 'mainPcbRev: ', mainPcbRev)

        sub1PcbName = ''
        sub1PcbRev = ''
        if traceSub1 != '':
            sub1PcbName = getPcbName(traceSub1)
            m = re.search('REV([.\d]+)I', sub1PcbName)
            if m:
                sub1PcbRev = m.group(1)
            else:
                sub1PcbRev = ''
            print('sub1PcbName: ', sub1PcbName, 'sub1PcbRev: ', sub1PcbRev)

        var2.set(f'{traceMain}, {mainPcbName}, {mainPcbRev}')
        var3.set(f'{traceSub1}, {sub1PcbName}, {sub1PcbRev}')


if __name__ == '__main__':
    root = Tk()
    var1 = StringVar()
    var2 = StringVar()
    var3 = StringVar()
    Button(root, text="popup", command = lambda: runPackDialog(var1, var2, var3)).pack(fill=X)
    Label(root, textvariable=var1).pack(fill=X)
    Label(root, textvariable=var2).pack(anchor=W)
    Label(root, textvariable=var3).pack(anchor=W)
    Button(root, text="bye", command=root.quit).pack(fill=X)
      
    root.mainloop()