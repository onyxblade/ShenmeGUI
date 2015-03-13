require 'fiddle'
require 'fiddle/import'
require 'fiddle/types'

module ShenmeGUI
  module FileDialog
    extend Fiddle::Importer
    dlload 'comdlg32', 'user32'
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
    extern 'HWND GetForegroundWindow()'

    def self.construct_OPENFILENAME(params={})
      filter = params[:filter] ? "#{params[:filter]}\0#{params[:filter]}\0\0" : 0
      title = params[:title] || 0
      flags = 0x00880000
      flags += 0x00000200 if params[:multiselect]
      flags += 0x10000000 if params[:showhidden]

      path = "\0" * 1024
      ofn = Struct_OPENFILENAME.malloc
      ofn.lStructSize = sizeof(ofn)
      ofn.hwndOwner = self.GetForegroundWindow
      ofn.lpstrFilter = filter
      ofn.lpstrCustomFilter = 0
      ofn.nMaxCustFilter = 0
      ofn.nFilterIndex = 0
      ofn.lpstrFile = path
      ofn.nMaxFile = path.size
      ofn.lpstrFileTitle = 0
      ofn.nMaxFileTitle = 0
      ofn.lpstrInitialDir = 0
      ofn.lpstrTitle = title
      ofn.nFileOffset = 0
      ofn.nFileExtension = 0
      ofn.lpstrDefExt = 0
      ofn.lCustData = 0
      ofn.lpfnHook = 0
      ofn.lpTemplateName = 0

      ofn.Flags = flags

      [ofn, path]
    end

    def self.get_open_file_name(params={})
      ofn, path = construct_OPENFILENAME(params)
      GetOpenFileName(ofn)
      ofn = nil
      path = path.split("\0")
      path = path[1..-1].collect{|x| "#{path[0]}\\#{x}"} if path.size > 1
      path
    end

    def self.get_save_file_name(params={})
      ofn, path = construct_OPENFILENAME(params)
      GetSaveFileName(ofn)
      ofn = nil
      path
    end

  end
end
