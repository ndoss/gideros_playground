
Software used in this proof of concept:

* Gideros Mobile (http://www.giderosmobile.com/)
* R.U.B.E. box2d editor (alpha stage):  http://www.iforce2d.net/b2deditor/
* JSON4Lua library: http://json.luaforge.net/


How to create a new json file and run it:

* Get the R.U.B.E. box2d editor, edit, save
* The editor leaves c/c++ type comments (i.e.,  // comment) in the 
  output json file.  The JSON4Lua library doesn't handle the comments 
  so they must be removed
* Edit main.lua to use the json file you just created

Issues:

* No user interaction w/ box2d objects
* Big json files seem to kill the gideros player or editor, not sure which one
* Nowhere close to being a full solution to anything .. only tested on a 
  very small subset of rube output
