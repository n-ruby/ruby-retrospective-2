class Collection
  include Enumerable

  attr_reader :songs

  def initialize(songs = [])
    @songs = songs
  end

  def each
    @songs.each { |song| yield song }
  end

  def self.parse(songs_string)
    songs_list = songs_string.split("\n\n").map do |song_string|
      name, artist, album = song_string.split("\n")
      Song.new name, artist, album
    end
    new songs_list
  end

  def artists
    @songs.map(&:artist).uniq
  end

  def albums
    @songs.map(&:album).uniq
  end

  def names
    @songs.map(&:name).uniq
  end

  def adjoin(other)
    Collection.new((songs + other.songs).uniq)
  end

  def filter(criteria)
    Collection.new select { |song| criteria.checkup.call song }
  end
end

class Song
  attr_reader :artist, :album, :name

  def initialize(name, artist, album)
    @name, @artist, @album = name, artist, album
  end
end

module Criteria
  def self.artist(artist)
    Filter.new { |song| song.artist == artist }
  end

  def self.album(album)
    Filter.new { |song| song.album == album }
  end

  def self.name(name)
    Filter.new { |song| song.name == name }
  end
end

class Filter
  attr_reader :checkup

  def initialize(&checkup)
    @checkup = checkup
  end

  def &(other)
    Filter.new { |song| checkup.call song and other.checkup.call song }
  end

  def |(other)
    Filter.new { |song| checkup.call song or other.checkup.call song }
  end

  def !
    Filter.new { |song| not checkup.call song }
  end
end
