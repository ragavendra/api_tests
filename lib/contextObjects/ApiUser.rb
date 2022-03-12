class ApiUser
  attr_accessor :memberService
  attr_accessor :cardService 

  def initialize(opts)
    @opts = opts
    @memberService = MemberService.new(@opts)
    @cardService = CardService.new(@opts)
   end
end
