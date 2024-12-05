-- 1.12版所有坐骑的ID，https://www.wowhead.com/classic/items/miscellaneous/mounts，点复制按钮
MountIDs = {19902, 19872, 13335, 13086, 2411, 216570, 19029, 20221, 21176, 13325, 2414, 18242, 19030, 18766, 18902, 18776, 8632, 18778, 18241, 8629, 18767, 18777, 216492, 5655, 8631, 5656, 18246, 18247, 8630, 18244, 12327, 18248, 228747, 18785, 228238, 12353, 8595, 14062, 18243, 12354, 18245, 12302, 23720, 12303, 13322, 13331, 191480, 18793, 8563, 5872, 18791, 18796, 5665, 12351, 18787, 5873, 8588, 5668, 18788, 18790, 1132, 228746, 23193, 13334, 18773, 8591, 18797, 13321, 13327, 13332, 228748, 15277, 18768, 5864, 13328, 18789, 216549, 18786, 8592, 2413, 13329, 18798, 21218, 21736, 18772, 12325, 2415, 13317, 15290, 211498, 13333, 211499, 13326, 5874, 8586, 18795, 21321, 12326, 13323, 15292, 18774, 12330, 1133, 15293, 16339, 13324, 901, 8583, 8627, 18794, 16344, 8628, 5875, 8589, 8633, 16343, 21323, 1041, 21324, 875, 1134, 8590, 16338, 5663}

-- 中英字典
L = {}
setmetatable(
    L,
    {
        __call = function(self, name)
            return GetLocale() == 'zhCN' and self[name] or name
        end
    }
)
-- 远程武器
L['Bows'] = '弓'
L['Crossbows'] = '弩'
L['Guns'] = '枪械'
L['Thrown'] = '投掷武器'
L['Shoot Bow'] = '弓射击'
L['Shoot Crossbow'] = '弩射击'
L['Shoot Gun'] = '枪械射击'
L['Throw'] = '投掷'
L['Auto Shot'] = '自动射击' -- 猎人
L['Shoot'] = '射击' -- 魔杖
-- 术士
L['Demon Skin'] = '恶魔皮肤'
L['Immolate'] = '献祭'
L['Corruption'] = '腐蚀术'
L['Curse of Agony'] = '痛苦诅咒'
L['Drain Life'] = '吸取生命'
L['Demon Armor'] = '魔甲术'
L['Siphon Life'] = '生命虹吸'
L['Dark Pact'] = '黑暗契约'
L['Shadow Trance'] = '暗影冥思'
L['Shadow Bolt'] = '暗影箭'
L['Health Funnel'] = '生命通道'
L['Drain Mana'] = '吸取法力'
-- 怪物种类
L['Elemental'] = '元素生物'
L['Mechanical'] = '机械'
-- 通用技能
L['Shadowmeld'] = '影遁'
L['Prowl'] = '潜伏'
-- 猎人技能
L['Serpent Sting'] = '毒蛇钉刺'
L['Scorpid Sting'] = '毒蝎钉刺'
L['Viper Sting'] = '蝰蛇钉刺'
L["Hunter's Mark"] = '猎人印记'
L['Concussive Shot'] = '震荡射击'
L['Arcane Shot'] = '奥术射击'
L['Aspect of the Monkey'] = '灵猴守护'
L['Wing Clip'] = '摔绊'
L['Raptor Strike'] = '猛禽一击'
L['Mongoose Bite'] = '猫鼬撕咬'
L['Counterattack'] = '反击'
L['Growl'] = '低吼'
L['Bite'] = '撕咬'
L['Claw'] = '爪击'
L['Aspect of the Wolf'] = '孤狼守护' -- 乌龟服，30级学到
L['Bestial Wrath'] = '狂野怒火'
L['Call Pet'] = '召唤宠物'
L['Revive Pet'] = '复活宠物'
L['Mend Pet'] = '治疗宠物'
