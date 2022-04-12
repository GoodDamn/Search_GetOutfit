# Search_GetOutfit
iOS-app for Olympiad Trajectory.

API calls and getting some information from the PostgRest server http://spb.getoutfit.co:3000

Parameters which app uses in HTTP-Request:

  - /limit= - set limit of result (integer number as argument)
  
  - /name=like.*{sth}* - find the name which contains in strings
  
  - /size=gte.{some integer number} - find rows where size param is greater then number. (For the 'price' parameter is the same)
  
  - /size=lte.{some integer number} - find rows where size param is less then number. (For the 'price' parameter is the same)

  - /category_id=eq.{some integer number} - find rows where category_id is equal to your number.

  - /color=in.(Красный,Синий,...) - find rows where someone word from your collection contains in database's string (Size parameter uses too)

  - /order={name of parameter}.asc - sort the results in order of descending(desc) or ascending(asc).
