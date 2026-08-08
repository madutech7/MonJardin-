from pbxproj import XcodeProject
import glob

def main():
    project = XcodeProject.load('MonJardin.xcodeproj/project.pbxproj')
    swift_files = glob.glob('MonJardin/**/*.swift', recursive=True)
    if glob.glob('MonJardinApp.swift'):
        swift_files.append('MonJardinApp.swift')
        
    for file in swift_files:
        print(f"Adding {file}")
        try:
            results = project.get_files_by_path(file)
            if not results:
                project.add_file(file, force=False, target_name='MonJardin')
            else:
                print(f"{file} already in project")
        except Exception as e:
            print(f"Error adding {file}: {e}")
        
    project.save()
    print("Project saved.")

if __name__ == '__main__':
    main()
