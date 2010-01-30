require 'test_helper'

class DocumentTest < ActiveSupport::TestCase
 
  def test_validations
    groupie = users(:groupie) 

    cat = Category.new({:name => "Root Level", :description => "Root Level Category"})
    cat.group = groups(:cool_kids)
    cat.save
    
    doc = Document.new
    assert !doc.valid?, "Document can be saved with no params"
    
    doc.title = "Test Doc"
    doc.category = cat
    doc.user = groupie
    
    assert doc.valid?, "Document needs title, category, and user"  
  end
  
  def test_autosets_owner
    ActiveRecord::Base.accessor = nil #Reset
    
    cat = Category.new({:name => "Root Level", :description => "Root Level Category", :user_id => users(:admin).id})
    cat.group = groups(:cool_kids)
    cat.save
 
    ActiveRecord::Base.accessor = users(:groupie) 
    doc = Document.new({:title => "Test Doc", :category_id => cat.id})
    assert doc.valid?, "Document owner autoset"
  end
    
  def test_group
    groupie = users(:groupie) 
    ActiveRecord::Base.accessor = groupie
    
    cool_kids = groups(:cool_kids)
    cat = Category.new({:name => "Root Level", :description => "Root Level Category", :group_id => cool_kids.id})
    cat.save
    
    doc = Document.new({:title => "Test Doc", :category_id => cat.id})
    if doc.save
      assert_equal doc.group, cat.group, "Document inherits group from category"
    else
      flunk "Document failed to save"
    end
  end
  
  def test_authentication
    groupie = users(:groupie)
    patron = users(:patron)
    regular = users(:regular)
    admin = users(:admin)

    cool_kids = groups(:cool_kids)
    patroons = groups(:patroons)
   
    cat = Category.new({:name => "Root Level", :description => "Root Level Category", :user_id => admin.id, :group_id=>cool_kids.id})
    cat.save
 
    ActiveRecord::Base.accessor = groupie
    #Default document
    doc = Document.new({:title => "Test Doc", :category_id => cat.id})
    doc.save

    [groupie, patron, regular, admin, nil].each do |u|
      ActiveRecord::Base.accessor = u
      assert doc.allowed_to_read, "All allowed to read default document"
    end
    [].each do |u|
      ActiveRecord::Base.accessor = u
      assert !doc.allowed_to_read, "No one cannot read a default document"
    end
    [groupie, patron, admin].each do |u|
      ActiveRecord::Base.accessor = u
      assert doc.allowed_to_save, "Group, Owner, Admin can write a default document"
    end
    [regular, nil].each do |u|
      ActiveRecord::Base.accessor = u
      assert !doc.allowed_to_save, "Regular users cannot write a default document"
    end

    #Hidden document
    ActiveRecord::Base.accessor = groupie
    doc.readable = false
    doc.save
    [groupie, patron, admin].each do |u|
      ActiveRecord::Base.accessor = u
      assert doc.allowed_to_read, "Group, Owner, Admin can allowed to read hidden document"
    end
    [regular, nil].each do |u|
      ActiveRecord::Base.accessor = u
      assert !doc.allowed_to_read, "Regular users cannot read a hidden document"
    end
    [groupie, patron, admin].each do |u|
      ActiveRecord::Base.accessor = u
      assert doc.allowed_to_save, "Group, Owner, Admin can write a hidden document"
    end
    [regular, nil].each do |u|
      ActiveRecord::Base.accessor = u
      assert !doc.allowed_to_save, "Regular users cannot write a hidden document"
    end
    
    #Public document
    ActiveRecord::Base.accessor = groupie
    doc.readable = true
    doc.writable = true
    doc.save
    [groupie, patron, admin, regular, nil].each do |u|
      ActiveRecord::Base.accessor = u
      assert doc.allowed_to_read, "Everyone can read public document"
    end
    [].each do |u|
      ActiveRecord::Base.accessor = u
      assert !doc.allowed_to_read, "No one cannot read a public document"
    end
    [groupie, patron, admin, regular].each do |u|
      ActiveRecord::Base.accessor = u
      assert doc.allowed_to_save, "All users can write a public document"
    end
    [nil].each do |u|
      ActiveRecord::Base.accessor = u
      #See category unit test for a note
      #assert !doc.allowed_to_save, "Users must log in before writing a document"
    end
  end
end
