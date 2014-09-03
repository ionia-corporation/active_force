class Whizbang < ActiveForce::SObject

  field :id,                   from: 'Id'
  field :checkbox,             from: 'Checkbox_Label'
  field :text,                 from: 'Text_Label'
  field :date,                 from: 'Date_Label'
  field :datetime,             from: 'DateTime_Label'
  field :picklist_multiselect, from: 'Picklist_Multiselect_Label'
  field :boolean,              from: 'Boolean_Label'
  field :estimated_close_date

end
