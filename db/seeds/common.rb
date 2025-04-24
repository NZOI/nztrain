%w[superadmin admin staff organiser author].each do |name|
  Role.find_or_create_by!(name: name)
end

rootuser = User
  .create_with(
    username: "System",
    name: "System",
    email: "nztrain@gmail.com",
    password: SecureRandom.base64(18),
    roles: [Role.find_by!(name: "superadmin")]
  )
  .find_or_create_by!(id: 0)

["system/mailer/email", "system/mailer/password", "recaptcha/public_key", "recaptcha/private_key"].each do |setting|
  Setting.find_or_create_by!(key: setting)
end

Setting
  .create_with(value: Random.new.rand(2E9.to_i).to_s)
  .find_or_create_by!(key: "submissions/shuffle")

Group
  .create_with(
    name: "Everyone",
    owner: rootuser
  )
  .find_or_create_by(id: 0)

languages = YAML.safe_load(File.read(File.expand_path("db/languages.yml", Rails.root))).with_indifferent_access
langfields = %i[name compiler compiler_command interpreter interpreter_command lexer interpreted compiled extension source_filename exe_extension processes]
languages.each do |grpid, grpcfg|
  groupopts = grpcfg.slice(:name)
  group = LanguageGroup.where(identifier: grpid).first_or_create!
  group.update_attributes(groupopts)

  grpcfg[:variants].each do |langid, langcfg|
    langopts = langcfg.reverse_merge(grpcfg).slice(*langfields).merge(group_id: group.id)
    language = Language.where(identifier: langid).first_or_create!
    language.update_attributes(langopts)
  end

  group.update_attributes(current_language_id: group.languages.find_by_identifier(grpcfg[:current]).id)
end

ProblemSeries.where(identifier: "COCI").first_or_create!.update_attributes(name: "Croatian Open Competition in Informatics", importer_type: "Problems::COCI::Importer")

Entity.find_or_create_by(name: "New Zealand Olympiad in Informatics", entity_type: "Organisation") do |entity|
  entity.entity_id = Organisation.create.id
end
