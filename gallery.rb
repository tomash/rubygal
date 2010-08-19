class Gallery
  attr_accessor :images
  
  def initialize
    self.images = []
  end
  
  def get_binding
    return binding()
  end
end
