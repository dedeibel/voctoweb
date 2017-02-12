module Frontend
  module FeedsHelper
    include ::Feeds::Helper

    # rendered by _navbar_feeds.haml
    def feed_structure
      menu = [
          { :left =>{ :content => 'News', :href => '/news.atom' } },
          { :left => { :content => 'RSS, last 100', :href => '/updates.rdf' } },
          { :left => { :content => 'Podcast feed of the last two years', :href => '/podcast.xml' },
                :right =>
                    { :content => 'SD Quality', :href => '/podcast_sd.xml', :title =>  'Podcast feed of the last two years (SD)'} },
          { :left => { :content => 'Podcast audio feed of the last year', :href => '/podcast-audio-only.xml' } },
          { :left => { :content => 'Podcast archive feed, everything older than two years', :href => '/podcast-archive.xml' },
                :right =>
                    { :content => 'SD Quality', :href => '/podcast-archive_sd.xml', :title =>  'Podcast archive feed, everything older than two years (SD)'} } ]

      if @conference && @conference.downloaded_events_count > 0
        menu += add_feeds_for_conference_recordings(@conference)
      end
      menu
    end

    private

    def add_feeds_for_conference_recordings(conference)
      sub_menu = []
      sorted_mime_types = conference.mime_types.sort_by(& MimeType::RELEVANCE_COMPARATOR)
      sorted_mime_types.each do |mime_type, mime_type_name|
        mime_type_sub_entry = {
            :left => {
            :indented => 'indented',
            :content  => MimeType.humanized_mime_type(mime_type),
            :href => podcast_folder_feed_url(acronym: conference.acronym, mime_type: mime_type_name),
            :title => MimeType.humanized_mime_type(mime_type) }
        }

        if MimeType.is_video(mime_type)
          mime_type_sub_entry[:right] = {
              :content => 'SD Quality',
              :href => podcast_folder_feed_url(acronym: conference.acronym, mime_type: mime_type_name),
              :title => MimeType.humanized_mime_type(mime_type) + ' (SD)'
          }
        end
        sub_menu.push(mime_type_sub_entry)
      end

      unless sub_menu.empty?
        sub_menu.unshift({:headline => "Podcast feeds for #{conference.acronym}"})
      end

      sub_menu
    end

  end
end
