class NekoController < ApplicationController
  # ApplicationControllerを継承せず、直接ActionController::Baseを継承
  # これにより認証を完全にスキップ
  layout 'application'

  def index
    require 'neko_gem'
    @neko_art = NekoGem::AsciiArt.cat
    @random_neko_art = NekoGem::AsciiArt.random_cat
  end

  def random
    require 'neko_gem'
    @random_neko_art = NekoGem::AsciiArt.random_cat
    render json: { neko: @random_neko_art }
  end
end
