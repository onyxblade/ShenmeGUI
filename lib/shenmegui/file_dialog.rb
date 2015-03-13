require 'fiddle'
require 'fiddle/import'
require 'fiddle/types'

module ShenmeGUI
  module FileDialog
    extend Fiddle::Importer
    dlload 'comdlg32'
    include Fiddle::Win32Types
    Struct_OPENFILENAME = struct <<-EOS.gsub %r{^\s+}, ''
      DWORD lStructSize,
      HWND hwndOwner,
      HINSTANCE hInstance,
      LPCSTR lpstrFilter,
      LPSTR lpstrCustomFilter,
      DWORD nMaxCustFilter,
      DWORD nFilterIndex,
      LPSTR lpstrFile,
      DWORD nMaxFile,
      LPSTR lpstrFileTitle,
      DWORD nMaxFileTitle,
      LPCSTR lpstrInitialDir,
      LPCSTR lpstrTitle,
      DWORD Flags,
      WORD nFileOffset,
      WORD nFileExtension,
      LPCSTR lpstrDefExt,
      long* lCustData,
      int lpfnHook,
      LPCSTR lpTemplateName
    EOS
    extern 'BOOL GetOpenFileName(struct OPENFILENAME*)'
    extern 'BOOL GetSaveFileName(struct OPENFILENAME*)'

    def self.get_open_file_name
      path = "\0"*512
      ofn = Struct_OPENFILENAME.malloc
      ofn.lStructSize = sizeof(ofn)
      ofn.hwndOwner = 0
      ofn.lpstrFilter = 0
      ofn.lpstrCustomFilter = 0
      ofn.nMaxCustFilter = 0
      ofn.nFilterIndex = 0
      ofn.lpstrFile = path
      ofn.nMaxFile = path.size
      ofn.lpstrFileTitle = 0
      ofn.nMaxFileTitle = 0
      ofn.lpstrInitialDir = 0
      ofn.lpstrTitle = 0
      ofn.nFileOffset = 0
      ofn.nFileExtension = 0
      ofn.lpstrDefExt = 0
      ofn.lCustData = 0
      ofn.lpfnHook = 0
      ofn.lpTemplateName = 0

      ofn.Flags = 0x10882200

      GetOpenFileName(ofn)
      ofn = nil
      path
    end
  end
end

#path = ShenmeGUI::FileDialog.get_open_file_name
#path = path.force_encoding('GBK').encode('UTF-8')
#path = path.split("\0")
#puts path