from PIL import Image

class Navigator:
    def get_screen(self):
        # Mock implementation
        return Image.new('1', (128, 64))

    def recog_ref(self):
        found_ic = list()

        # display_image = None
        # TODO: add blank image initialization
        display_image = Image.new('1', (128, 64))

        display_image = self.get_screen()
