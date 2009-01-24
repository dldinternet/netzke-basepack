class NetzkeFormPanelField < ActiveRecord::Base
  belongs_to :layout, :class_name => "NetzkeLayout"
  
  acts_as_list :scope => :layout

  def self.create_layout_for_widget(widget)
    layout = NetzkeLayout.create(:widget_name => widget.id_name, :items_class => self.name, :user_id => NetzkeLayout.user_id)

    columns = Netzke::Column.default_fields_for_widget(widget)

    for c in columns
      config_for_create = c.merge(:layout_id => layout.id).stringify_values!
      create(config_for_create)
    end
    
    layout
  end
end