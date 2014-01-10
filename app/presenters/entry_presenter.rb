module EntryPresenter
  extend ActiveSupport::Concern

  module ClassMethods
    def headings
      columns.values
    end

    def columns
      @columns
    end
  end

  def fields
    self.class.columns.keys.map { |field| send(field) }
  end
end
