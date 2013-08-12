module ApplicationHelper
  def link_to_add_fields(name, f, association)
    new_object = f.object.send(association).klass.new
    id = new_object.object_id
    fields = f.fields_for(association, new_object, child_index: id) do |builder|
      render("edit_#{association.to_s.pluralize}", f: builder)
    end
    link_to(name, '#', id: "add_#{association.downcase}", data: {id: id, fields: fields.gsub("\n", "")}, class: "add_#{association.to_s.pluralize} small blue button")
  end
end