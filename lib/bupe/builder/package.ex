defmodule BUPE.Builder.Package do
  @moduledoc """
    Package definition builder

    ### Required configuration values

    * `version` - default: 3.0 (required)
    * `unique_identifier` - (required)
    * `identifier` -
    * `title` -
    * `language` -
    * `datetime` -

    ### Optional conf values

    * `contributor` - Represents the name of a person, organization, etc. that
      played a secondary role in the creation of the content.
    * `creator` -  Represents the name of a person, organization, etc.
      responsible for the creation of the content
    * `coverage` -
    * `date` - Define the publication date. The publication date is not the
      same as the last modification date. See: http://www.w3.org/TR/NOTE-datetime
    * `description` -
    * `format` -
    * `publisher` -
    * `relation` -
    * `rights` -
    * `source` -
    * `subject` -
    * `type` -
  """

  alias BUPE.Builder.Templates

  def save(config, output) do
    content = Templates.content_template(config)
    File.write!(output, content)
  end
end
