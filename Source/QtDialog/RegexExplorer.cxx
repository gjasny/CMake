/*============================================================================
  CMake - Cross Platform Makefile Generator
  Copyright 2015 Kitware, Inc., Gregor Jasny

  Distributed under the OSI-approved BSD License (the "License");
  see accompanying file Copyright.txt for details.

  This software is distributed WITHOUT ANY WARRANTY; without even the
  implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  See the License for more information.
============================================================================*/

#include "RegexExplorer.h"

RegexExplorer::RegexExplorer(QWidget* p)
{
  this->setupUi(this);

  for (int i = 1; i < cmsys::RegularExpression::NSUBEXP; ++i) {
    matchNumber->addItem(
      QString("Match %1").arg(QString::number(i)),
      QVariant(i));
  }
  matchNumber->setCurrentIndex(0);
}

void RegexExplorer::setBackgroundColor(QWidget* widget, const QColor& color)
{
  QPalette palette = widget->palette();
  palette.setColor(QPalette::Base, color);
  palette.setColor(QPalette::Background, color);
  widget->setPalette(palette);
}

void RegexExplorer::on_inputText_textChanged()
{
  if (!m_regex.is_valid()) return;

  QString plainText = inputText->toPlainText();

  bool matched = m_regex.find(plainText.toStdString());

  QColor backgroundColor = matched ? Qt::green : Qt::red;
  setBackgroundColor(match0, backgroundColor);

  if (!matched) return;

  match0->setPlainText(QString::fromStdString(m_regex.match(0)));

  on_matchNumber_currentIndexChanged(matchNumber->currentIndex());
}

void RegexExplorer::on_regularExpression_textChanged(const QString& text)
{
  bool validExpression = m_regex.compile(text.toStdString());

  QColor backgroundColor = validExpression ? Qt::green : Qt::red;
  setBackgroundColor(regularExpression, backgroundColor);

  if (validExpression) {
    on_inputText_textChanged();
  }
}

void RegexExplorer::on_matchNumber_currentIndexChanged(int index)
{
  if (!m_regex.is_valid()) return;

  QVariant data = matchNumber->itemData(index);
  int idx = data.toInt();

  if (idx < 1 || idx >= cmsys::RegularExpression::NSUBEXP) return;

  matchN->setPlainText(QString::fromStdString(m_regex.match(idx)));
}
