module ErrorHandlingMacros
  def enable_production_error_handling
    before do
      PagesController.stub(:should_raise_exceptions?).and_return(false)
    end
  end
end

