from tkinter import *


def checkSanityId(ent):
    entGet = ent.get()
    if (len(entGet) == 11 or len(entGet) == 12) and entGet[0:2].isalpha() and entGet[2:].isdigit():
        return True
    else: 
        print('checkSanityId' , f'"{entGet}"')
        wrong = "Wrong ID!!!  "
        ent.insert(0, wrong)
        ent.selection_range(0, END)
        ent.focus_set()
        return False
    
def lastEntrySanity(event, ents, vars, win):
    #print('lastEntrySanity')
    if not checkSanityId(ents[0]):
        return False
    
    if not checkSanityTrace(ents[1]):
        ents[1].focus_set()
        return False
    
    ent2Get = ents[1].get()
    ent3Get = ents[2].get()
    vars[2].set(ent3Get.strip())
    #print('lastEntrySanity', ent2Get, ent3Get, ents[2].cget('state'))
    if not ent2Get.isalnum():
        ents[1].insert(0, "Wrong TraceID!!!  ")
        ents[1].selection_range(0, END)
        ents[1].focus_set()
        return False
    
    if ents[2].cget('state')=='disabled':
        pass
    else:
        if ent2Get == ent3Get or not ent3Get.isalnum():
            ents[2].insert(0, "Wrong TraceID!!!  ")
            ents[2].selection_range(0, END)
            ents[2].focus_set()
            return False
    
    vars[1].set(ent2Get.upper())
    vars[2].set(ent3Get.upper())
    
    win.destroy()
    #pass

def checkSanityTrace(ent):
    entGet = ent.get()
    if not entGet.isalnum():
        wrong = "Wrong TraceID!!!  "
        ent.insert(0, wrong)
        ent.selection_range(0,END)   #len(wrong)
        return False
    else:
        return True


def sanity(id, traceMain, traceSub1):
    print(f'sanity {id}, {traceMain}, {traceSub1}')
    print(len(id), id[0:2])
    return True