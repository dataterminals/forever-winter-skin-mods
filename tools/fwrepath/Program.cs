// fwrepath — edit cooked UE5.4 assets for The Forever Winter skin-mod retargeting.
// Uses UAssetAPI to inspect and rename FNames (export/import/reference names) inside
// legacy cooked .uasset/.uexp produced by `retoc to-legacy`, re-serializing with
// correct offsets. See repo README.
//
//   inspect <asset.uasset> [namefilter]
//   rename  <in.uasset> <out.uasset> OLD=NEW [OLD2=NEW2 ...]
//
// Needs a .usmap (unversioned props). Path via FW_USMAP env or ./mappings.usmap.
using UAssetAPI;
using UAssetAPI.UnrealTypes;
using UAssetAPI.Unversioned;

static string FindUsmap()
{
    var env = Environment.GetEnvironmentVariable("FW_USMAP");
    if (!string.IsNullOrWhiteSpace(env) && File.Exists(env)) return env;
    foreach (var c in new[] { "mappings.usmap",
        @"D:\Github Repositories\forever-winter-datamine\datamine\mappings\ForeverWinter-5.4.2.usmap" })
        if (File.Exists(c)) return c;
    throw new FileNotFoundException("no .usmap (set FW_USMAP)");
}

static UAsset Load(string path, Usmap m) => new UAsset(path, EngineVersion.VER_UE5_4, m);

if (args.Length < 2) { Console.WriteLine("modes: inspect <a.uasset> [filter] | rename <in> <out> OLD=NEW ..."); return 1; }

var usmap = new Usmap(FindUsmap());
var mode = args[0];

if (mode == "inspect")
{
    var asset = Load(args[1], usmap);
    string filter = args.Length > 2 ? args[2] : null;
    Console.WriteLine($"PackageFlags: {asset.PackageFlags}");
    Console.WriteLine($"FolderName (header package name): {asset.FolderName}");
    var names = asset.GetNameMapIndexList();
    Console.WriteLine($"=== NAME MAP ({names.Count}) ===");
    for (int i = 0; i < names.Count; i++)
    {
        var s = names[i].ToString();
        if (filter == null || s.Contains(filter, StringComparison.OrdinalIgnoreCase))
            Console.WriteLine($"  [{i}] {s}");
    }
    Console.WriteLine($"=== EXPORTS ({asset.Exports.Count}) ===");
    for (int i = 0; i < asset.Exports.Count; i++)
    {
        var e = asset.Exports[i];
        Console.WriteLine($"  #{i} '{e.ObjectName}'  type={e.GetType().Name}  classIdx={e.ClassIndex.Index}");
    }
    Console.WriteLine($"=== IMPORTS ({asset.Imports.Count}) ===");
    foreach (var im in asset.Imports)
        Console.WriteLine($"  '{im.ObjectName}'  class={im.ClassName}  pkg={im.ClassPackage}");
    return 0;
}

if (mode == "rename")
{
    if (args.Length < 4) { Console.WriteLine("rename <in> <out> OLD=NEW ..."); return 1; }
    var inPath = args[1]; var outPath = args[2];
    var asset = Load(inPath, usmap);
    for (int k = 3; k < args.Length; k++)
    {
        var parts = args[k].Split('=', 2);
        if (parts.Length != 2) { Console.WriteLine($"bad pair: {args[k]}"); return 1; }
        var oldN = new FString(parts[0]); var newN = new FString(parts[1]);
        // (1) name map — export/import/reference names
        int idx = asset.SearchNameReference(oldN);
        if (idx >= 0) { asset.SetNameReference(idx, newN); Console.WriteLine($"  renamed name[{idx}] '{parts[0]}' -> '{parts[1]}'"); }
        else Console.WriteLine($"  (no name-map entry '{parts[0]}')");
        // (2) header FolderName — the package name retoc's to-zen reads to compute the FPackageId.
        //     Name-map edits do NOT touch this, so the chunk id would otherwise stay the base id.
        if (asset.FolderName != null && asset.FolderName.ToString() == parts[0])
        {
            asset.FolderName = newN;
            Console.WriteLine($"  set FolderName (header pkg name) -> '{parts[1]}'");
        }
    }
    Directory.CreateDirectory(Path.GetDirectoryName(Path.GetFullPath(outPath)));
    asset.Write(outPath);
    Console.WriteLine($"wrote {outPath}");
    return 0;
}

Console.WriteLine("unknown mode"); return 1;
