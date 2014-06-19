module ErrorHandlingMacros
  def enable_production_error_handling
    before do
      allow(PagesController).to receive(:should_raise_exceptions?).and_return(false)
    end
  end
end

