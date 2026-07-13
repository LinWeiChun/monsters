USE monsters;

INSERT INTO annoyance_types (code, type_name, display_order)
VALUES
  ('ACADEMIC', '課業', 1),
  ('CAREER', '事業', 2),
  ('LOVE', '愛情', 3),
  ('FRIENDSHIP', '友情', 4),
  ('FAMILY', '親情', 5),
  ('OTHER', '其他', 6)
ON DUPLICATE KEY UPDATE
  code = VALUES(code),
  type_name = VALUES(type_name),
  display_order = VALUES(display_order);
