module ApplicationHelper
  def link_to_add_fields(name, f, association)
    new_object = f.object.send(association).klass.new
    id = new_object.object_id
    fields = f.fields_for(association, new_object, child_index: id) do |builder|
      render("edit_#{association.to_s.pluralize}", f: builder)
    end
    link_to(name, '#', id: "add_#{association.downcase}", data: {id: id, fields: fields.gsub("\n", "")}, class: "add_fields small blue button")
  end
  
  def suggested_fields
    [
      [ "Hobbies"                   ,  "hobbies"                  ,  "string"     ],
      [ "Favorite Magazine"         ,  "favorite-magazine"        ,  "string"     ],
      [ "Favourite Movie"           ,  "favourite-movie"          ,  "string"     ],
      [ "Leisure Activities"        ,  "leisure-activities"       ,  "string"     ],
      [ "Favourite Sport"           ,  "favourite-sport"          ,  "string"     ],
      [ "Favourite Sports Team"     ,  "favourite-sports-team"    ,  "string"     ],
      [ "Sport Participation"       ,  "sport-participation"      ,  "string"     ],
      [ "Car Type Owned"            ,  "car-type-owned"           ,  "string"     ],
      [ "Favourite Car"             ,  "favourite-car"            ,  "string"     ],
      [ "Pet Owner"                 ,  "pet-owner"                ,  "string"     ],
      [ "Recent Reading"            ,  "recent-reading"           ,  "string"     ],
      [ "Favourite Restaurant"      ,  "favourite-restaurant"     ,  "string"     ],
      [ "Favourite Food"            ,  "favourite-food"           ,  "string"     ],
      [ "Awards"                    ,  "awards"                   ,  "string"     ],
      [ "Recent Seminar"            ,  "recent-seminar"           ,  "string"     ],
      [ "Recent Vacation"           ,  "recent-vacation"          ,  "string"     ],
      [ "Personal Development"      ,  "personal-development"     ,  "string"     ],
      [ "Hometown"                  ,  "hometown"                 ,  "string"     ],
      [ "Birthday"                  ,  "birthday"                 ,  "datetime"   ],
      [ "Address"                   ,  "address"                  ,  "string"     ],
      [ "Marital Status"            ,  "marital-status"           ,  "string"     ],
      [ "Partner Name"              ,  "partner-name"             ,  "string"     ],
      [ "Goals"                     ,  "goals"                    ,  "string"     ],
      [ "Dislikes"                  ,  "dislikes"                 ,  "string"     ],
      [ "Clubs"                     ,  "clubs"                    ,  "string"     ],
      [ "Previous Work"             ,  "previous-work"            ,  "string"     ],
      [ "Previous Residence"        ,  "previous-residence"       ,  "string"     ],
      [ "Faith"                     ,  "faith"                    ,  "string"     ],
      [ "Post Secondary"            ,  "post-secondary"           ,  "string"     ],
      [ "Children"                  ,  "children"                 ,  "string"     ],
      [ "Business Challenges"       ,  "business-challenges"      ,  "string"     ],
      [ "Business Competitors"      ,  "business-competitors"     ,  "string"     ],
      [ "Associations"              ,  "associations"             ,  "string"     ],
      [ "Publications"              ,  "publications"             ,  "string"     ],
      [ "Past Experiences"          ,  "past-experiences"         ,  "string"     ]
    ]
  end
end