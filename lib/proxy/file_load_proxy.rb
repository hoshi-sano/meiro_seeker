module MyDungeonGame
  class FileLoadProxy
    class << self
      def load_image(file_path)
        Image.load(file_path)
      end

      def load_image_tiles(file_path, xcount, ycount)
        res = []
        Image.load_tiles(file_path, xcount, ycount).each_with_index do |img, i|
          x = i % xcount
          y = i / xcount
          res[y] ||= []
          res[y][x] = img
        end
        res
      end
    end
  end
end
