class Whizbang < ActiveForce::SObject

  field :id,                   from: 'Id'
  field :checkbox,             from: 'Checkbox_Label', as: :boolean
  field :text,                 from: 'Text_Label'
  field :date,                 from: 'Date_Label', as: :date
  field :datetime,             from: 'DateTime_Label', as: :datetime
  field :picklist_multiselect, from: 'Picklist_Multiselect_Label', as: :multipicklist
  field :boolean,              from: 'Boolean_Label',  as: :boolean
  field :percent,              from: 'Percent_Label',  as: :percent
  field :estimated_close_date, as: :datetime
  field :updated_from,         as: :datetime
  field :dirty_attribute,      as: :boolean

  before_save :set_as_updated_from_rails
  after_save :mark_dirty

  validates :percent, presence: true, if: :boolean

  private

  def set_as_updated_from_rails
    self.updated_from = 'Rails'
  end

  def mark_dirty
    self.dirty_attribute = true
  end

end