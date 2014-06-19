require 'spec_helper'

module NavigationMacros

  def it_renders_for(path, level, depth = 1)
    it "renders for '#{path}'" do
      @page = Page.find_by_path(path)
      navigation_for_level(level, depth)
      expected = yield

      expect(output_buffer).to be_html_equivalent expected
    end
  end

  def it_does_not_render_for(path, level, depth = 1)
    it "does not render for '#{path}'" do
      @page = Page.find_by_path(path)
      navigation_for_level(level, depth)

      expect(output_buffer).to be_html_equivalent ''
    end
  end

end

RSpec::Matchers.define :be_html_equivalent do |expected|
  match do |actual|
    stripped_html(actual) == stripped_html(expected)
  end

  failure_message_for_should do |actual|
    "expected that\n#{actual}\nwould be equlivent to\n#{expected}"
  end

  failure_message_for_should_not do |actual|
    "expected that\n#{actual} would not be equlivent to\n#{expected}"
  end

  description do
    "be HTML equlivent to #{expected}"
  end
end

describe NavigationHelper, type: :helper do
  extend NavigationMacros

  def logger
  end

  def stripped_html(tags)
    tags.gsub(/\n/, '').gsub(/> +</, '><').strip
  end

  def assert_html_equivalent(expected, actual=output_buffer)
    expect(stripped_html(actual)).to eq stripped_html(expected)
  end

  def navigation_for_level(level, depth)
    if (level == :primary)
      send("#{level}_navigation")
    else
      send("#{level}_navigation", depth: depth)
    end
  end

  context "when pages exist" do

    before do
      StandardTree.build_complex
      StandardTree.add_cousins(Page.find_by_path('/uncle'))
      StandardTree.add_slices_beneath(Page.home)
    end

    context "#primary_navigation" do

      it_renders_for('/', :primary) do
        <<-EOF
        <ul id="primary_navigation">
          <li class="first active nav-home"><a href="/">Home</a></li>
          <li class="nav-parent"><a href="/parent">Parent</a></li>
          <li class="nav-aunt"><a href="/aunt">Aunt</a></li>
          <li class="last nav-uncle"><a href="/uncle">Uncle</a></li>
        </ul>
        EOF
      end

      it_renders_for('/parent', :primary) do
        <<-EOF
        <ul id="primary_navigation">
          <li class="first nav-home"><a href="/">Home</a></li>
          <li class="active nav-parent"><a href="/parent">Parent</a></li>
          <li class="nav-aunt"><a href="/aunt">Aunt</a></li>
          <li class="last nav-uncle"><a href="/uncle">Uncle</a></li>
        </ul>
        EOF
      end

      it_renders_for('/parent/child', :primary) do
        <<-EOF
        <ul id="primary_navigation">
          <li class="first nav-home"><a href="/">Home</a></li>
          <li class="active nav-parent"><a href="/parent">Parent</a></li>
          <li class="nav-aunt"><a href="/aunt">Aunt</a></li>
          <li class="last nav-uncle"><a href="/uncle">Uncle</a></li>
        </ul>
        EOF
      end

      it "allows customer id for primary_navigation" do
        @page = Page.home
        primary_navigation('footer_navigation')

        expect(output_buffer).to be_html_equivalent <<-EOF
        <ul id="footer_navigation">
          <li class="first active nav-home"><a href="/">Home</a></li>
          <li class="nav-parent"><a href="/parent">Parent</a></li>
          <li class="nav-aunt"><a href="/aunt">Aunt</a></li>
          <li class="last nav-uncle"><a href="/uncle">Uncle</a></li>
        </ul>
        EOF
      end

      context "when pages are inactive" do
        before do
          @page = Page.find_by_path('/parent')

          inactive_page = Page.find_by_path('/uncle')
          inactive_page.active = false
          inactive_page.save!
        end

        it "does not render inactive pages" do
          primary_navigation

          expect(output_buffer).to be_html_equivalent <<-EOF
          <ul id="primary_navigation">
            <li class="first nav-home">
              <a href="/">Home</a>
            </li>
            <li class="active nav-parent">
              <a href="/parent">Parent</a>
            </li>
            <li class="last nav-aunt">
              <a href="/aunt">Aunt</a>
            </li>
          </ul>
          EOF
        end

      end

      context "when pages are not shown in nav" do
        before do
          @page = Page.find_by_path('/parent')

          inactive_page = Page.find_by_path('/uncle')
          inactive_page.show_in_nav = false
          inactive_page.save!
        end

        it "does not render pages that are not shown in nav" do
          primary_navigation

          expect(output_buffer).to be_html_equivalent <<-EOF
          <ul id="primary_navigation">
            <li class="first nav-home">
              <a href="/">Home</a>
            </li>
            <li class="active nav-parent">
              <a href="/parent">Parent</a>
            </li>
            <li class="last nav-aunt">
              <a href="/aunt">Aunt</a>
            </li>
          </ul>
          EOF
        end

      end

      context "when home page isn't shown in nav" do
        before do
          @page = Page.find_by_path('/parent')

          inactive_page = Page.home
          inactive_page.show_in_nav = false
          inactive_page.save!
        end

        it "not render pages that are not shown in nav" do
          primary_navigation

          expect(output_buffer).to be_html_equivalent <<-EOF
          <ul id="primary_navigation">
            <li class="first active nav-parent">
              <a href="/parent">Parent</a>
            </li>
            <li class="nav-aunt">
              <a href="/aunt">Aunt</a>
            </li>
            <li class="last nav-uncle">
              <a href="/uncle">Uncle</a>
            </li>
          </ul>
          EOF
        end

      end

      context "when parent has no slices" do
        before do
          @page = Page.find_by_path('/parent')
          @page.slices.destroy_all
          @page.save!

          child = Page.find_by_path('/parent/child')
          child.active = false
          child.save
        end

        it "link to first active child" do
          primary_navigation

          expect(output_buffer).to be_html_equivalent <<-EOF
          <ul id="primary_navigation">
            <li class="first nav-home">
              <a href="/">Home</a>
            </li>
            <li class="active nav-parent">
              <a href="/parent/sibling">Parent</a>
            </li>
            <li class="nav-aunt">
              <a href="/aunt">Aunt</a>
            </li>
            <li class="last nav-uncle">
              <a href="/uncle">Uncle</a>
            </li>
          </ul>
          EOF
        end

      end
    end

    context "#secondary_navigation" do
      context "with a depth of 1" do
        it_does_not_render_for '/', :secondary
        it_does_not_render_for '/aunt', :secondary

        it_renders_for('/parent', :secondary) do
          <<-EOF
          <ul id="secondary_navigation">
            <li class="first nav-parent-child">
              <a href="/parent/child">Child</a>
            </li>
            <li class="nav-parent-sibling">
              <a href="/parent/sibling">Sibling</a>
            </li>
            <li class="last nav-parent-youngest">
              <a href="/parent/youngest">Youngest</a>
            </li>
          </ul>
          EOF
        end

        it_renders_for('/parent/child', :secondary) do
          <<-EOF
          <ul id="secondary_navigation">
            <li class="first active nav-parent-child">
              <a href="/parent/child">Child</a>
            </li>
            <li class="nav-parent-sibling">
              <a href="/parent/sibling">Sibling</a>
            </li>
            <li class="last nav-parent-youngest">
              <a href="/parent/youngest">Youngest</a>
            </li>
          </ul>
          EOF
        end

        it_renders_for('/parent/child/grand-child', :secondary) do
          <<-EOF
          <ul id="secondary_navigation">
            <li class="first active nav-parent-child">
              <a href="/parent/child">Child</a>
            </li>
            <li class="nav-parent-sibling">
              <a href="/parent/sibling">Sibling</a>
            </li>
            <li class="last nav-parent-youngest">
              <a href="/parent/youngest">Youngest</a>
            </li>
          </ul>
          EOF
        end
      end

      context "with a depth of 2" do
        it_does_not_render_for '/', :secondary, 2
        it_does_not_render_for '/aunt', :secondary, 2

        it_renders_for('/parent', :secondary, 2) do
          <<-EOF
          <ul id="secondary_navigation">
            <li class="first nav-parent-child">
              <a href="/parent/child">Child</a>
              <ul>
                <li class="first last nav-parent-child-grand-child">
                  <a href="/parent/child/grand-child">Grand child</a>
                </li>
              </ul>
            </li>
            <li class="nav-parent-sibling">
              <a href="/parent/sibling">Sibling</a>
            </li>
            <li class="last nav-parent-youngest">
              <a href="/parent/youngest">Youngest</a>
            </li>
          </ul>
          EOF
        end

        it_renders_for('/parent/child', :secondary, 2) do
          <<-EOF
          <ul id="secondary_navigation">
            <li class="first active nav-parent-child">
              <a href="/parent/child">Child</a>
              <ul>
                <li class="first last nav-parent-child-grand-child">
                  <a href="/parent/child/grand-child">Grand child</a>
                </li>
              </ul>
            </li>
            <li class="nav-parent-sibling">
              <a href="/parent/sibling">Sibling</a>
            </li>
            <li class="last nav-parent-youngest">
              <a href="/parent/youngest">Youngest</a>
            </li>
          </ul>
          EOF
        end

        it_renders_for('/parent/child/grand-child', :secondary, 2) do
          <<-EOF
          <ul id="secondary_navigation">
            <li class="first active nav-parent-child">
              <a href="/parent/child">Child</a>
              <ul>
                <li class="first active last nav-parent-child-grand-child">
                  <a href="/parent/child/grand-child">Grand child</a>
                </li>
              </ul>
            </li>
            <li class="nav-parent-sibling">
              <a href="/parent/sibling">Sibling</a>
            </li>
            <li class="last nav-parent-youngest">
              <a href="/parent/youngest">Youngest</a>
            </li>
          </ul>
          EOF
        end
      end
    end

    context "#navigation" do
      it "allow specification of id and class" do
        @page = Page.find_by_path('/parent/child')

        expect(navigation(
          page: @page, depth: 1, id: 'nav-id', class: 'nav-class'
        )).to be_html_equivalent <<-EOF
        <ul class="nav-class" id="nav-id">
          <li class="first active nav-parent-child">
            <a href="/parent/child">Child</a>
          </li>
          <li class="nav-parent-sibling">
            <a href="/parent/sibling">Sibling</a>
          </li>
          <li class="last nav-parent-youngest">
            <a href="/parent/youngest">Youngest</a>
          </li>
        </ul>
        EOF
      end

      it "render 2 levels of navigation" do
        @page = Page.find_by_path('/')
        expect(navigation(page: Page.home, depth: 2)).to be_html_equivalent <<-EOF
        <ul>
          <li class="first active nav-home">
            <a href="/">Home</a>
          </li>
          <li class="nav-parent">
            <a href="/parent">Parent</a>
            <ul>
              <li class="first nav-parent-child">
                <a href="/parent/child">Child</a>
              </li>
              <li class="nav-parent-sibling">
                <a href="/parent/sibling">Sibling</a>
              </li>
              <li class="last nav-parent-youngest">
                <a href="/parent/youngest">Youngest</a>
              </li>
            </ul>
          </li>
          <li class="nav-aunt">
            <a href="/aunt">Aunt</a>
          </li>
          <li class="last nav-uncle">
            <a href="/uncle">Uncle</a>
            <ul>
              <li class="first last nav-uncle-cousin">
                <a href="/uncle/cousin">Cousin</a>
              </li>
            </ul>
          </li>
        </ul>
        EOF
      end
    end
  end

  context "with sets and entries" do
    before do
      StandardTree.build_minimal
      StandardTree.add_article_set(Page.home)
    end

    it_renders_for('/articles', :secondary) { '' }
  end

  context "with external links" do
    before do
      home, parent = StandardTree.build_minimal
      external = Page.make(parent: home, name: 'External', external_url: 'http://www.withassociates.com', active: true, show_in_nav: true)
    end

    it_renders_for('/', :primary) do
      <<-EOF
        <ul id="primary_navigation">
          <li class="first active nav-home"><a href="/">Home</a></li>
          <li class="nav-parent"><a href="/parent">Parent</a></li>
          <li class="last nav-external"><a href="http://www.withassociates.com">External</a></li>
        </ul>
      EOF
    end

  end
end

