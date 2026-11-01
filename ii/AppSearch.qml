pragma Singleton

import qs.modules.common
import qs.modules.common.functions
import Quickshell

/**
 * - Eases fuzzy searching for applications by name
 * - Guesses icon name for window class name
 */
Singleton {
    id: root
    property bool sloppySearch: Config.options?.search.sloppy ?? false
    property real scoreThreshold: 0.2
    property var substitutions: ({
        "code-url-handler": "visual-studio-code",
        "Code": "visual-studio-code",
        "gnome-tweaks": "org.gnome.tweaks",
        "pavucontrol-qt": "pavucontrol",
        "wps": "wps-office2019-kprometheus",
        "wpsoffice": "wps-office2019-kprometheus",
        "footclient": "foot",
    })
    property var regexSubstitutions: [
        {
            "regex": /^steam_app_(\d+)$/,
            "replace": "steam_icon_$1"
        },
        {
            "regex": /Minecraft.*/,
            "replace": "minecraft"
        },
        {
            "regex": /.*polkit.*/,
            "replace": "system-lock-screen"
        },
        {
            "regex": /gcr.prompter/,
            "replace": "system-lock-screen"
        }
    ]

    // Deduped list to fix double icons
    readonly property list<DesktopEntry> listOld: Array.from(DesktopEntries.applications.values)
        .filter((app, index, self) => 
            index === self.findIndex((t) => (
                t.id === app.id
            ))
    )
    
    readonly property var preppedNames: list.map(a => ({
        name: Fuzzy.prepare(`${a.name} `),
        entry: a
    }))

    readonly property var preppedIcons: list.map(a => ({
        name: Fuzzy.prepare(`${a.icon} `),
        entry: a
    }))

    function fuzzyQueryOld(search: string): var { // Idk why list<DesktopEntry> doesn't work
        if (root.sloppySearch) {
            const results = list.map(obj => ({
                entry: obj,
                score: Levendist.computeScore(obj.name.toLowerCase(), search.toLowerCase())
            })).filter(item => item.score > root.scoreThreshold)
                .sort((a, b) => b.score - a.score)
            return results
                .map(item => item.entry)
        }

        return Fuzzy.go(search, preppedNames, {
            all: true,
            key: "name"
        }).map(r => {
            return r.obj.entry
        });
    }

    readonly property list<DesktopEntry> list: Array.from(DesktopEntries.applications.values)
        .filter((app, index, self) => index === self.findIndex(t => t.id === app.id))

    readonly property var searchEntries: list.map(app => ({
        namePrepared: Fuzzy.prepare(app.name),
        keywordsPrepared: Fuzzy.prepare(app.keywords ? app.keywords.join(' ') : ''),
        genericNamePrepared: Fuzzy.prepare(app.genericName || ''),
        entry: app
    }))

    function simpleMatch(search, str) {
        if (!str) return false;
        return str.toLowerCase().indexOf(search.toLowerCase()) !== -1;
    }

    function fuzzyQuery(search) {
        if (!search || search.length === 0) return [];

        // --- 模式1：sloppySearch（简单的子串匹配，不排序，不计算分数）---
        if (root.sloppySearch) {
            const lowerSearch = search.toLowerCase();
            const results = [];
            for (let i = 0; i < list.length; i++) {
                const app = list[i];
                // 检查 name / keywords / genericName 是否包含搜索词
                if (simpleMatch(lowerSearch, app.name) ||
                    (app.keywords && app.keywords.some(k => simpleMatch(lowerSearch, k))) ||
                    simpleMatch(lowerSearch, app.genericName)) {
                    results.push(app);
                }
            }
            return results;  // 保持原顺序，不去重排序（性能优先）
        }

        // --- 模式2：标准模糊搜索（使用 Fuzzysort 多键匹配）---
        const results = Fuzzy.go(search, root.searchEntries, {
            all: true,
            keys: ['namePrepared', 'keywordsPrepared', 'genericNamePrepared'],
            // 可选：默认评分已经很好，不需要自定义 scoreFn
            // 如果希望调整权重，可以取消注释下面的 scoreFn
            /*
            scoreFn: (matchResults) => {
                let total = 0;
                let count = 0;
                for (let i = 0; i < matchResults.length; i++) {
                    if (matchResults[i] && matchResults[i].score > 0) {
                        total += matchResults[i].score * (i === 0 ? 1.0 : 0.8);
                        count++;
                    }
                }
                return count ? total / count : 0;
            }
            */
        });

        return results && results.length ? results.map(r => r.obj.entry) : [];
    }

    function iconExists(iconName) {
        if (!iconName || iconName.length == 0) return false;
        return (Quickshell.iconPath(iconName, true).length > 0) 
            && !iconName.includes("image-missing");
    }

    function getReverseDomainNameAppName(str) {
        return str.split('.').slice(-1)[0]
    }

    function getKebabNormalizedAppName(str) {
        return str.toLowerCase().replace(/\s+/g, "-");
    }

    function getUndescoreToKebabAppName(str) {
        return str.toLowerCase().replace(/_/g, "-");
    }

    function guessIcon(str) {
        if (!str || str.length == 0) return "image-missing";

        // Quickshell's desktop entry lookup
        const entry = DesktopEntries.byId(str);
        if (entry) return entry.icon;

        // Normal substitutions
        if (substitutions[str]) return substitutions[str];
        if (substitutions[str.toLowerCase()]) return substitutions[str.toLowerCase()];

        // Regex substitutions
        for (let i = 0; i < regexSubstitutions.length; i++) {
            const substitution = regexSubstitutions[i];
            const replacedName = str.replace(
                substitution.regex,
                substitution.replace,
            );
            if (replacedName != str) return replacedName;
        }

        // Icon exists -> return as is
        if (iconExists(str)) return str;


        // Simple guesses
        const lowercased = str.toLowerCase();
        if (iconExists(lowercased)) return lowercased;

        const reverseDomainNameAppName = getReverseDomainNameAppName(str);
        if (iconExists(reverseDomainNameAppName)) return reverseDomainNameAppName;

        const lowercasedDomainNameAppName = reverseDomainNameAppName.toLowerCase();
        if (iconExists(lowercasedDomainNameAppName)) return lowercasedDomainNameAppName;

        const kebabNormalizedGuess = getKebabNormalizedAppName(str);
        if (iconExists(kebabNormalizedGuess)) return kebabNormalizedGuess;

        const undescoreToKebabGuess = getUndescoreToKebabAppName(str);
        if (iconExists(undescoreToKebabGuess)) return undescoreToKebabGuess;

        // Search in desktop entries
        const iconSearchResults = Fuzzy.go(str, preppedIcons, {
            all: true,
            key: "name"
        }).map(r => {
            return r.obj.entry
        });
        if (iconSearchResults.length > 0) {
            const guess = iconSearchResults[0].icon
            if (iconExists(guess)) return guess;
        }

        const nameSearchResults = root.fuzzyQuery(str);
        if (nameSearchResults.length > 0) {
            const guess = nameSearchResults[0].icon
            if (iconExists(guess)) return guess;
        }

        // Quickshell's desktop entry lookup
        const heuristicEntry = DesktopEntries.heuristicLookup(str);
        if (heuristicEntry) return heuristicEntry.icon;

        // Give up
        return "application-x-executable";
    }
}
