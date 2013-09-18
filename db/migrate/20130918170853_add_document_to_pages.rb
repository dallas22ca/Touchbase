class AddDocumentToPages < ActiveRecord::Migration
  def change
    add_reference :pages, :document, index: true
  end
end
